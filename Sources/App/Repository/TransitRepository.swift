import Foundation
import Fluent

struct TransitRepository {
    let database: Database

    func save(_ transit: Transit) async throws -> Transit {
        try await transit.save(on: database)
        return transit
    }

    func addProposed(driverId: UUID, to transitId: UUID) async throws {
        let item = Transit.ProposedDriver()
        item.$driver.id = driverId
        item.$transit.id = transitId

        try await item.save(on: database)
    }

    func addRejected(driverId: UUID, to transitId: UUID) async throws {
        let item = Transit.RejectedDriver()
        item.$driver.id = driverId
        item.$transit.id = transitId

        try await item.save(on: database)
    }
    
    func listAll() async throws -> [Transit] {
        try await Transit.query(on: database)
            .with(\.$driver)
            .with(\.$client)
            .with(\.$proposedDrivers)
            .with(\.$driversRejections)
            .with(\.$from)
            .with(\.$to)
            .all()
    }
    
    func findBy(transitId: UUID) async throws -> Transit? {
        try await Transit.query(on: database)
            .filter(\.$id == transitId)
            .with(\.$driver)
            .with(\.$client)
            .with(\.$proposedDrivers)
            .with(\.$driversRejections)
            .with(\.$from)
            .with(\.$to)
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
