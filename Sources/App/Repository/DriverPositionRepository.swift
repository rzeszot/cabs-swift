import Foundation
import Fluent

struct DriverPositionRepository {
    let database: Database

    func save(_ position: DriverPosition) async throws -> DriverPosition {
        try await position.save(on: database)
        return position
    }

    func findByDriverAndSeenAtBetweenOrderBySeenAtAsc(driver: Driver, from: Date, to: Date) async throws -> [DriverPosition] {
        let driverId = try driver.requireID()

        return try await DriverPosition.query(on: database)
            .filter(\.$driver.$id == driverId)
            .filter(\.$seenAt >= from)
            .filter(\.$seenAt <= to)
            .all()
    }

}
