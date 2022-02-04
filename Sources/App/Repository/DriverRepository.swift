import Foundation
import Fluent

struct DriverRepository {
    let database: Database

    func save(_ driver: Driver) async throws -> Driver {
        try await driver.save(on: database)
        return driver
    }

    func findBy(id: UUID) async throws -> Driver? {
        try await Driver.query(on: database)
            .filter(\.$id == id)
            .first()
    }

    func all() async throws -> [Driver] {
        try await Driver.query(on: database)
            .all()
    }
}
