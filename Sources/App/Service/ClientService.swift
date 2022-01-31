import Foundation
import Vapor

class ClientService {
    private let clientRepository: ClientRepository

    init(clientRepository: ClientRepository) {
        self.clientRepository = clientRepository
    }

    func registerClient(name: String, lastName: String, kind: String, paymentKind: String) async throws -> Client {
        guard let kind = Client.Kind(rawValue: kind) else { throw Abort(.badRequest) }
        guard let paymentKind = Client.PaymentKind(rawValue: paymentKind) else { throw Abort(.badRequest) }

        let client = Client()
        client.name = name
        client.lastName = lastName
        client.kind = kind
        client.clientKind = .individual
        client.defaultPaymentKind = paymentKind

        return try await clientRepository.save(client)
    }

    func load(id: UUID) async throws -> Client? {
        try await clientRepository.findBy(id: id)
    }

    func all() async throws -> [Client] {
        try await clientRepository.all()
    }

    func changeDefaultPaymentType(clientId: UUID, paymentKind: String) async throws {
        guard let paymentKind = Client.PaymentKind(rawValue: paymentKind) else { throw Abort(.badRequest) }
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }

        client.defaultPaymentKind = paymentKind
        _ = try await clientRepository.save(client)
    }

    func upgradeToVIP(clientId: UUID) async throws {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }

        client.kind = .vip
        _ = try await clientRepository.save(client)
    }

    func downgradeToRegular(clientId: UUID) async throws {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }

        client.kind = .normal
        _ = try await clientRepository.save(client)
    }

}
