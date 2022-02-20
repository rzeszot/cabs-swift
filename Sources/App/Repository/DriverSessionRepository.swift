import Foundation
import Fluent

struct DriverSessionRepository {
    let database: Database

    func save(_ session: DriverSession) async throws -> DriverSession {
        try await session.save(on: database)
        return session
    }

    func findBy(id: UUID) async throws -> DriverSession? {
        try await DriverSession.query(on: database)
            .filter(\.$id == id)
            .first()
    }

    func all() async throws -> [DriverSession] {
        try await DriverSession.query(on: database)
            .all()
    }

    func findBy(driver: Driver) async throws -> [DriverSession] {
        let driverId = try driver.requireID()

        return try await DriverSession.query(on: database)
            .filter(\.$driver.$id == driverId)
            .all()
    }

    func findBy(driver: Driver, loggedAfter since: Date) async throws -> [DriverSession] {
        let driverId = try driver.requireID()

        return try await DriverSession.query(on: database)
            .filter(\.$driver.$id == driverId)
            .filter(\.$loggedAt >= since)
            .all()
    }

    func findTopByDriverAndLoggedOutAtIsNullOrderByLoggedAtDesc(driver: Driver) async throws -> DriverSession? {
        let driverId = try driver.requireID()

        return try await DriverSession.query(on: database)
            .filter(\.$driver.$id == driverId)
            .filter(\.$loggedOutAt == nil)
            .sort(\.$loggedAt, .descending)
            .first()
    }

    func findAllByLoggedOutAtNullAndDriverInAndCarClassIn(drivers: [Driver], carClasses: [String]) async throws -> [DriverSession] {
        let driversIds = try drivers.map { try $0.requireID() }

        return try await DriverSession.query(on: database)
            .with(\.$driver)
            .filter(\.$driver.$id ~~ driversIds)
            .filter(\.$carClass ~~ carClasses)
            .filter(\.$loggedOutAt == nil)
            .sort(\.$loggedAt, .descending)
            .all()
    }

}
