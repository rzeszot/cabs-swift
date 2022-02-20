import Foundation
import Fluent

struct DriverRepository {
    let database: Database

    func save(_ driver: Driver) async throws -> Driver {
        try await driver.save(on: database)
        return try await findBy(id: try driver.requireID())!
    }

    func findBy(id: UUID) async throws -> Driver? {
        try await Driver.query(on: database)
            .with(\.$attributes)
            .filter(\.$id == id)
            .first()
    }

    func all() async throws -> [Driver] {
        try await Driver.query(on: database)
            .with(\.$attributes)
            .all()
    }
}
