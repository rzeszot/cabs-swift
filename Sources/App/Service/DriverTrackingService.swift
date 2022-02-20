import Vapor

struct DriverIsNotActiveError: Error {
    let message: String
}

class DriverTrackingService {

    private let positionRepository: DriverPositionRepository
    private let driverRepository: DriverRepository
    private let distanceCalculator: DistanceCalculator
    private let clock: Clock

    init(
        positionRepository: DriverPositionRepository,
        driverRepository: DriverRepository,
        distanceCalculator: DistanceCalculator,
        clock: Clock
    ) {
        self.positionRepository = positionRepository
        self.driverRepository = driverRepository
        self.distanceCalculator = distanceCalculator
        self.clock = clock
    }

    func registerPosition(driverId: UUID, latitude: Double, longitude: Double) async throws -> DriverPosition {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }

        guard driver.status == .active else { throw DriverIsNotActiveError(message: "driver id = \(driverId)") }

        let position = DriverPosition()
        position.$driver.id = driverId
        position.seenAt = Date()
        position.latitude = latitude
        position.longitude = longitude

        _ = try await positionRepository.save(position)

        return try await positionRepository.findBy(id: try position.requireID())!
    }

    func calculateTravelledDistance(driverId: UUID, from: Date, to: Date) async throws -> Double {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        let positions = try await positionRepository.findByDriverAndSeenAtBetweenOrderBySeenAtAsc(driver: driver, from: from, to: to)

        var distanceTravelled: Double = 0


        if positions.count > 1 {
            var previousPosition = positions[0]

            for position in positions {
                distanceTravelled += distanceCalculator.calculateByGeo(
                    latitudeFrom: previousPosition.latitude,
                    longitudeFrom: previousPosition.longitude,
                    latitudeTo: position.latitude,
                    longitudeTo: position.longitude
                )

                previousPosition = position
            }
        }

        return distanceTravelled
    }

    func getLastPositionsFor(driverId: UUID) async throws -> [DriverPosition] {
        guard (try await driverRepository.findBy(id: driverId)) != nil else { throw Abort(.notFound) }
        let positions = try await positionRepository.getLastPositionsFor(driverId: driverId)
        return positions
    }

}
