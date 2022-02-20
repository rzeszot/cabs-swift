import Foundation
import Fluent
import Vapor

struct DriverTransckingController: RouteCollection {
    let trackingService: DriverTrackingService

    func boot(routes: RoutesBuilder) throws {
        routes.group("driver-positions") { positions in
            positions.post(use: create)

            positions.group(":driver_id") { driver in
                driver.get("total", use: calculateTravelledDistance)
                driver.get("all", use: getAllPositionsForDriver)
            }
        }
    }

    // MARK: -

    func create(request: Request) async throws -> DriverPositionResponseDTO {
        let dto = try request.content.decode(DriverPositionCreateDTO.self)
        let position = try await trackingService.registerPosition(driverId: dto.driverId, latitude: dto.latitude, longitude: dto.longitude)

        return DriverPositionResponseDTO(position: position)
    }

    func calculateTravelledDistance(request: Request) async throws -> DriverTotalDistanceResponseDTO {
        guard let driverId = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }
        let query = try request.query.decode(TotalQueryParams.self)

        let result = try await trackingService.calculateTravelledDistance(driverId: driverId, from: query.from, to: query.to)

        return DriverTotalDistanceResponseDTO(driverId: driverId, total: result)
    }

    struct TotalQueryParams: Content {
        let from: Date
        let to: Date
    }

    func getAllPositionsForDriver(request: Request) async throws -> DriverPositionsAllResponseDTO {
        guard let driverId = request.parameters.get("driver_id", as: UUID.self) else { throw Abort(.badRequest) }

        let positions = try await trackingService.getLastPositionsFor(driverId: driverId)
        return DriverPositionsAllResponseDTO(driverID: driverId, positions: positions)
    }

}
