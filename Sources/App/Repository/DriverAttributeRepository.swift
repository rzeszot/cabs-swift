import Foundation
import Fluent

struct DriverAttributeRepository {
    let database: Database

    func save(_ attribute: DriverAttribute) async throws -> DriverAttribute {
        try await attribute.save(on: database)
        return attribute
    }
}
