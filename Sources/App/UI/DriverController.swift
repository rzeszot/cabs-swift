import Foundation
import Fluent
import Vapor

struct DriverController: RouteCollection {
    let driverService: DriverService

    func boot(routes: RoutesBuilder) throws {
        routes.group("drivers") { drivers in
            drivers.get(use: all)
            drivers.post(use: createDrider)

            drivers.group(":driver_id") { driver in
                driver.post(use: updateDriver)
                driver.post("activate", use: activateDriver)
                driver.post("deactivate", use: deactivateDriver)
            }
        }
    }

    // MARK: -

    func createDrider(request: Request) async throws -> DriverResponseDTO {
        let dto = try request.content.decode(DriverCreateRequestDTO.self)

        let created = try await driverService.createDriver(license: dto.license, lastName: dto.lastName, firstName: dto.firstName, kind: .candidate, status: .inactive, photo: dto.photo)

        return DriverResponseDTO(driver: created)
    }

    func all(request: Request) async throws -> [DriverResponseDTO] {
        try await driverService.allDrivers().map(DriverResponseDTO.init(driver:))
    }

    func updateDriver(request: Request) async throws -> DriverResponseDTO {
        guard let id = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }
        guard let driver = try await driverService.load(driverId: id) else { throw Abort(.notFound) }

        // TODO?

        return DriverResponseDTO(driver: driver)
    }

    func activateDriver(request: Request) async throws -> DriverResponseDTO {
        guard let id = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }

        let driver = try await driverService.changeDriverStatus(driverId: id, status: .active)
        return DriverResponseDTO(driver: driver)
    }

    func deactivateDriver(request: Request) async throws -> DriverResponseDTO {
        guard let id = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }

        let driver = try await driverService.changeDriverStatus(driverId: id, status: .inactive)
        return DriverResponseDTO(driver: driver)
    }

    func getDriver(request: Request) async throws -> DriverResponseDTO {
        guard let id = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }

        guard let driver = try await driverService.load(driverId: id) else { throw Abort(.notFound) }

        return DriverResponseDTO(driver: driver)
    }

}
