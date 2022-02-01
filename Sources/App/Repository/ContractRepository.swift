import Foundation
import Fluent

struct ContractRepository {
    let database: Database

    func save(_ contract: Contract) async throws -> Contract {
        try await contract.save(on: database)
        return contract
    }

    func findBy(id: UUID) async throws -> Contract? {
        try await Contract.find(id, on: database)
    }

    func findBy(partnerName: String) async throws -> [Contract] {
        try await Contract.query(on: database)
            .filter(\.$partnerName == partnerName)
            .all()
    }

    func all() async throws -> [Contract] {
        try await Contract.query(on: database).all()
    }
}
