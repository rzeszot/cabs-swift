import Foundation
import Fluent

struct ContractRepository {
    let database: Database

    func save(_ contract: Contract) async throws -> Contract {
        try await contract.save(on: database)
        return contract
    }

    func findBy(id: UUID) async throws -> Contract? {
        try await Contract.query(on: database)
            .with(\.$attachments)
            .filter(\.$id == id)
            .first()
    }

    func findBy(partnerName: String) async throws -> [Contract] {
        try await Contract.query(on: database)
            .with(\.$attachments)
            .filter(\.$partnerName == partnerName)
            .all()
    }

    func all() async throws -> [Contract] {
        try await Contract.query(on: database)
            .with(\.$attachments)
            .all()
    }
}
