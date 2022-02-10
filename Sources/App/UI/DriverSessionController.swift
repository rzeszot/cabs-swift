import Foundation
import Fluent
import Vapor

struct DriverSessionController: RouteCollection {
    let driverSessionService: DriverSessionService
    let clock: Clock

    func boot(routes: RoutesBuilder) throws {
        routes.group("drivers") { drivers in
            drivers.group(":driver_id") { driver in
                driver.group("driver-sessions") { sessions in
                    sessions.get(use: listAllSessions)
                    sessions.post("login", use: logIn)
                    sessions.delete(use: logOutCurrent)
                    
                    sessions.group(":session_id") { session in
                        session.delete(use: logOut)
                    }
                }
            }
        }
    }

    // MARK: -

    func logIn(request: Request) async throws -> String {
        guard let driverId = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }
        let dto = try request.content.decode(DriverSessionLoginDTO.self)

        _ = try await driverSessionService.logIn(driverId: driverId, plateNumber: dto.plateNumber, carClass: dto.carClass, carBrand: dto.carBrand)
        return "{}"
    }

    func logOut(request: Request) async throws -> String {
        guard let sessionId = request.parameters.get("session_id", as: UUID.self) else { throw Abort(.badRequest) }

        try await driverSessionService.logOut(sessionId: sessionId)
        return "{}"
    }

    func logOutCurrent(request: Request) async throws -> String {
        guard let driverId = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }
        try await driverSessionService.logOutCurrentSession(driverId: driverId)
        return "{}"
    }

    func listAllSessions(request: Request) async throws -> [DriverSessionResponseDTO] {
        guard let driverId = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }

        let sessions = try await driverSessionService.findByDriver(driverId: driverId)

        return sessions.map(DriverSessionResponseDTO.init(session:))
    }

}
