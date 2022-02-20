import Foundation
import Fluent

struct AddressRepository {
    let database: Database

    func findBy(id: UUID) async throws -> Address? {
        try await Address.find(id, on: database)
    }

    func save(_ address: Address) async throws {
        try await address.save(on: database)
    }

    func isIdSet(address: Address) -> Bool {
        address.id != nil
    }

    func listAll() async throws -> [Address] {
        try await Address.query(on: database)
            .all()
    }
}
