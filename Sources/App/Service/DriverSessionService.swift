import Vapor
import Foundation

class DriverSessionService {

    private let driverRepository: DriverRepository
    private let carTypeService: CarTypeService
    private let driverSessionRepository: DriverSessionRepository
    private let clock: Clock

    init(
        driverRepository: DriverRepository,
        carTypeService: CarTypeService,
        driverSessionRepository: DriverSessionRepository,
        clock: Clock
    ) {
        self.driverRepository = driverRepository
        self.carTypeService = carTypeService
        self.driverSessionRepository = driverSessionRepository
        self.clock = clock
    }

    func logIn(driverId: UUID, plateNumber: String, carClass: String, carBrand: String) async throws -> DriverSession {
        guard let _ = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }

        let session = DriverSession()
        session.$driver.id = driverId
        session.loggedAt = clock.now()
        session.carClass = carClass
        session.carBrand = carBrand
        session.platesNumber = plateNumber

        _ = try await carTypeService.registerActiveCar(carClass: carClass)

        return try await driverSessionRepository.save(session)
    }

    func logOut(sessionId: UUID) async throws {
        guard let session = try await driverSessionRepository.findBy(id: sessionId) else { throw Abort(.notFound) }

        session.loggedOutAt = clock.now()
        _ = try await driverSessionRepository.save(session)

        try await carTypeService.unregisterCar(session.carClass)
    }

    func logOutCurrentSession(driverId: UUID) async throws {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        guard let session = try await driverSessionRepository.findTopByDriverAndLoggedOutAtIsNullOrderByLoggedAtDesc(driver: driver) else { throw Abort(.notFound) }

        session.loggedOutAt = clock.now()
        _ = try await driverSessionRepository.save(session)

        try await carTypeService.unregisterCar(session.carClass)
    }

    func findByDriver(driverId: UUID) async throws -> [DriverSession] {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        return try await driverSessionRepository.findBy(driver: driver)
    }

}
