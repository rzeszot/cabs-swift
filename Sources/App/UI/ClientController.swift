import Foundation
import Fluent
import Vapor

struct ClientController: RouteCollection {
    let clientService: ClientService

    func boot(routes: RoutesBuilder) throws {
        routes.group("clients") { clients in
            clients.get(use: all)
            clients.post(use: register)

            clients.group(":id") { client in
                client.get(use: find)

                client.post("upgrade", use: upgradeToVIP)
                client.post("downgrade", use: downgradeToRegular)
                client.post("change-default-payment-type", use: changeDefaultPaymentType)
            }
        }
    }

    // MARK: -

    func all(request: Request) async throws -> [ClientResponseDTO] {
        try await clientService.all().map(ClientResponseDTO.init(client:))
    }

    func find(request: Request) async throws -> ClientResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }

        if let client = try await clientService.load(id: id) {
            return ClientResponseDTO.init(client: client)
        } else {
            throw Abort(.notFound)
        }
    }

    func register(request: Request) async throws -> ClientResponseDTO {
        let dto = try request.content.decode(ClientRegisterRequestDTO.self)
        let created = try await clientService.registerClient(name: dto.name, lastName: dto.lastName, kind: dto.type, paymentKind: dto.defaultPaymentType)
        return ClientResponseDTO(client: created)
    }


    func upgradeToVIP(request: Request) async throws -> ClientResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }

        try await clientService.upgradeToVIP(clientId: id)
        return ClientResponseDTO(client: try await clientService.load(id: id)!)
    }

    func downgradeToRegular(request: Request) async throws -> ClientResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }

        try await clientService.downgradeToRegular(clientId: id)
        return ClientResponseDTO(client: try await clientService.load(id: id)!)
    }

    func changeDefaultPaymentType(request: Request) async throws -> ClientResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        let dto = try request.content.decode(ClientChangeDefaultPaymentTypeRequestDTO.self)

        try await clientService.changeDefaultPaymentType(clientId: id, paymentKind: dto.defaultPaymentType)
        return ClientResponseDTO(client: try await clientService.load(id: id)!)
    }

}
