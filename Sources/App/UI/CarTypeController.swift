import Foundation
import Fluent
import Vapor

struct CarTypeController: RouteCollection {
    let carTypeService: CarTypeService

    func boot(routes: RoutesBuilder) throws {
        routes.group("car-types") { types in
            types.post(use: create)
            types.get(use: list)

            types.group(":parameter") { paramter in
                paramter.get(use: find)

                paramter.post("activate", use: activate)
                paramter.post("deactivate", use: deactivate)

                paramter.post("register-car", use: registerCar)
                paramter.post("unregister-car", use: unregisterCar)
            }
        }
    }

    // MARK: -

    func activate(request: Request) async throws -> String {
        guard let id = request.parameters.get("parameter", as: UUID.self) else { throw Abort(.badRequest) }
        try await carTypeService.activate(id)
        return "{}"
    }


    func deactivate(request: Request) async throws -> String {
        guard let id = request.parameters.get("parameter", as: UUID.self) else { throw Abort(.badRequest) }
        try await carTypeService.deactivate(id)
        return "{}"
    }

    func registerCar(request: Request) async throws -> String {
        guard let carClass = request.parameters.get("parameter") else { throw Abort(.badRequest) }

        try await carTypeService.registerCar(carClass)
        return "{}"
    }

    func unregisterCar(request: Request) async throws -> String {
        guard let carClass = request.parameters.get("parameter") else { throw Abort(.badRequest) }

        try await carTypeService.unregisterCar(carClass)
        return "{}"
    }

    func create(request: Request) async throws -> CarTypeResponseDTO {
        let dto = try request.content.decode(CarTypeRequestDTO.self)
        let created = try await carTypeService.create(dto)

        return CarTypeResponseDTO(created)
    }

    func find(request: Request) async throws -> CarTypeResponseDTO {
        guard let id = request.parameters.get("parameter", as: UUID.self) else { throw Abort(.badRequest) }
        guard let carType = try await carTypeService.load(id) else { throw Abort(.notFound) }

        return CarTypeResponseDTO(carType)
    }

    func list(request: Request) async throws -> [CarTypeResponseDTO] {
        try await carTypeService.all()
            .map(CarTypeResponseDTO.init)
    }
}
