import Foundation
import Fluent
import Vapor

struct CarTypeController: RouteCollection {
    let carTypeService: CarTypeService

    func boot(routes: RoutesBuilder) throws {
//        routes.post("car-types", ":car_class", "register-car", use: registerCar)
//        routes.post("car-types", ":car_class", "unregister-car", use: unregisterCar)
        routes.post("car-types", use: create)
        routes.get("car-types", ":id", use: find)
        routes.get("car-types", use: list)
        routes.post("car-types", ":id", "activate", use: activate)
        routes.post("car-types", ":id", "deactivate", use: deactivate)
    }

    // MARK: -

    func activate(request: Request) async throws -> String {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        try await carTypeService.activate(id)
        return "{}"
    }


    func deactivate(request: Request) async throws -> String {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        try await carTypeService.deactivate(id)
        return "{}"
    }

    func registerCar(request: Request) async throws -> String {
        guard let carClass = request.parameters.get("car_class") else { throw Abort(.badRequest) }

        try await carTypeService.registerCar(carClass)
        return "{}"
    }

    func unregisterCar(request: Request) async throws -> String {
        guard let carClass = request.parameters.get("car_class") else { throw Abort(.badRequest) }

        try await carTypeService.unregisterCar(carClass)
        return "{}"
    }

    func create(request: Request) async throws -> CarTypeResponseDTO {
        let dto = try request.content.decode(CarTypeRequestDTO.self)
        let created = try await carTypeService.create(dto)

        return CarTypeResponseDTO(created)
    }

    func find(request: Request) async throws -> CarTypeResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        guard let carType = try await carTypeService.load(id) else { throw Abort(.notFound) }

        return CarTypeResponseDTO(carType)
    }

    func list(request: Request) async throws -> [CarTypeResponseDTO] {
        try await carTypeService.all()
            .map(CarTypeResponseDTO.init)
    }
}
