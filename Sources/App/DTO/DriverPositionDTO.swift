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
