import Foundation
import Fluent

struct TransitRepository {
    let database: Database

    func save(_ transit: Transit) async throws -> Transit {
        try await transit.save(on: database)
        return transit
    }
    
    func findBy(transitId: UUID) async throws -> Transit? {
        try await Transit.query(on: database)
            .filter(\.$id == transitId)
            .with(\.$driver)
            .with(\.$proposedDrivers)
            .with(\.$driversRejections)
            .first()
    }
    
    func findBy(client: Client) async throws -> [Transit] {
        let clientId = try client.requireID()

        return try await Transit.query(on: database)
            .filter(\.$client.$id == clientId)
            .all()
    }
    
    func findAllByDriverAndDateTimeBetween(driver: Driver, from: Date, to: Date) async throws -> [Transit] {
        let driverId = try driver.requireID()

        return try await Transit.query(on: database)
            .filter(\.$driver.$id == driverId)
            .filter(\.$dateTime > from)
            .filter(\.$dateTime < to)
            .all()
    }
    
    func findAllByClientAndFromAndStatusOrderByDateTimeDesc(client: Client, address: Address, status: Transit.Status) async throws -> [Transit] {
        let clientId = try client.requireID()
        let addressId = try address.requireID()

        return try await Transit.query(on: database)
            .filter(\.$client.$id == clientId)
            .filter(\.$from.$id == addressId)
            .filter(\.$status == status)
            .sort(\.$dateTime, .descending)
            .all()
    }

    func findAllByClientAndFromAndPublishedAfterAndStatusOrderByDateTimeDesc(client: Client, address: Address, when: Date, status: Transit.Status) async throws -> [Transit] {
        let clientId = try client.requireID()
        let addressId = try address.requireID()

        return try await Transit.query(on: database)
            .filter(\.$client.$id == clientId)
            .filter(\.$from.$id == addressId)
            .filter(\.$published == when)
            .filter(\.$status == status)
            .sort(\.$dateTime, .descending)
            .all()
    }

}
