import Vapor
import Foundation

struct DriverSessionLoginDTO: Content {
    let plateNumber: String
    let carClass: String
    let carBrand: String
}

struct DriverSessionResponseDTO: Content {
    let sessionId: UUID
    let driverId: UUID
    let carBrand: String
    let carClass: String
    let platesNumber: String

    let loggedAt: Date
    let loggedOutAt: Date?

    init(session: DriverSession) {
        sessionId = try! session.requireID()
        driverId = session.$driver.id
        carBrand = session.carBrand
        carClass = session.carClass
        platesNumber = session.platesNumber
        loggedAt = session.loggedAt
        loggedOutAt = session.loggedOutAt
    }
}
