import Foundation
import Fluent

struct DriverFeeRepository {
    let database: Database

    func save(_ fee: DriverFee) async throws -> DriverFee {
        try await fee.save(on: database)
        return fee
    }

    func findBy(driver: Driver) async throws -> DriverFee? {
        let driverId = try driver.requireID()

        return try await DriverFee.query(on: database)
            .filter(\.$driver.$id == driverId)
            .first()
    }

}
