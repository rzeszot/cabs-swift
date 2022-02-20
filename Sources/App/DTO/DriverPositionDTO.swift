import Vapor
import Foundation

struct DriverPositionCreateDTO: Content {
    let driverId: UUID
    let latitude: Double
    let longitude: Double
}

struct DriverPositionResponseDTO: Content {
    let driverId: UUID
    let latitude: Double
    let longitude: Double
    let seenAt: Date

    init(position: DriverPosition) {
        driverId = try! position.driver.requireID()
        latitude = position.latitude
        longitude = position.longitude
        seenAt = position.seenAt
    }
}

struct DriverTotalDistanceResponseDTO: Content {
    let driverId: UUID
    let total: Double

    init(driverId: UUID, total: Double) {
        self.driverId = driverId
        self.total = total
    }
}

struct DriverPositionsAllResponseDTO: Content {
    let driverId: UUID
    let positions: [PositionDTO]

    struct PositionDTO: Content {
        let latitude: Double
        let longitude: Double
        let seenAt: Date
    }

    init(driverID: UUID, positions: [DriverPosition]) {
        self.positions = positions.map { pos in
            PositionDTO(latitude: pos.latitude, longitude: pos.longitude, seenAt: pos.seenAt)
        }
        self.driverId = driverID
    }

}
