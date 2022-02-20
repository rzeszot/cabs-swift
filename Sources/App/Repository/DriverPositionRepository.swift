import Foundation
import Fluent

struct DriverPositionRepository {
    let database: Database

    func save(_ position: DriverPosition) async throws -> DriverPosition {
        try await position.save(on: database)
        return position
    }

    func findBy(id: UUID) async throws -> DriverPosition? {
        try await DriverPosition.query(on: database)
            .with(\.$driver)
            .filter(\.$id == id)
            .first()
    }

    func findByDriverAndSeenAtBetweenOrderBySeenAtAsc(driver: Driver, from: Date, to: Date) async throws -> [DriverPosition] {
        let driverId = try driver.requireID()

        return try await DriverPosition.query(on: database)
            .filter(\.$driver.$id == driverId)
            .filter(\.$seenAt >= from)
            .filter(\.$seenAt <= to)
            .all()
    }

    func findAverageDriverPositionSince(
        latitudeMin: Double,
        latitudeMax: Double,
        longitudeMin: Double,
        longitudeMax: Double,
        date: Date
    ) async throws -> [(driver: Driver, latitude: Double, longitude: Double)] {
        let positions = try await DriverPosition.query(on: database)
            .filter(\.$latitude >= latitudeMin)
            .filter(\.$latitude <= latitudeMax)
            .filter(\.$longitude >= longitudeMin)
            .filter(\.$longitude <= longitudeMax)
            .filter(\.$seenAt >= date)
            .all()
        
        // can't find any avg() syntax for `QueryBuilder` -> going into code
        // future me: forgive me

        var tmp: [Driver: [(latitude: Double, longitude: Double)]] = [:]
        
        for position in positions {
            tmp[position.driver, default: []].append((latitude: position.latitude, longitude: position.longitude))
        }
        
        var result: [(driver: Driver, latitude: Double, longitude: Double)] = []
        
        for (driver, coordinates) in tmp {
            let latitude = coordinates.reduce(coordinates.first!.latitude) { $0 + $1.latitude } / Double(coordinates.count)
            let longitude = coordinates.reduce(coordinates.first!.longitude) { $0 + $1.longitude } / Double(coordinates.count)
            
            result.append((driver: driver, latitude: latitude, longitude: longitude))
        }

        return result
    }

}
