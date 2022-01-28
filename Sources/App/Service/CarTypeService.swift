import Foundation
import Vapor

class CarTypeService {
    private let carTypeRepository: CarTypeRepository
    private let appProperties: AppProperties

    init(carTypeRepository: CarTypeRepository, appProperties: AppProperties) {
        self.carTypeRepository = carTypeRepository
        self.appProperties = appProperties
    }

    func load(_ id: UUID) async throws -> CarType? {
        try await carTypeRepository.findBy(id: id)
    }

    func create(_ dto: CarTypeRequestDTO) async throws -> CarType {
        let byCarClass = try await carTypeRepository.findBy(carClass: dto.carClass)

        if let byCarClass = byCarClass {
            byCarClass.description = dto.description
            return byCarClass
        } else {
            let carType = CarType(carClass: CarType.CarClass(rawValue: dto.carClass)!, description: dto.description, minNoOfCarsToActivateClass: dto.minNoOfCarsToActivateClass)
            try await carTypeRepository.save(carType)
            return carType
        }
    }

    func all() async throws -> [CarType] {
        try await carTypeRepository.all()
    }

    func registerCar(_ carClass: String) async throws {
        guard let carType = try await carTypeRepository.findBy(carClass: carClass) else { throw Abort(.notFound) }

        carType.registerCar()
        try await carTypeRepository.save(carType)
    }

    func unregisterCar(_ carClass: String) async throws {
        guard let carType = try await carTypeRepository.findBy(carClass: carClass) else { throw Abort(.notFound) }

        try carType.unregisterCar()
        try await carTypeRepository.save(carType)
    }

    func activate(_ id: UUID) async throws {
        guard let carType = try await load(id) else { throw Abort(.notFound) }

        try carType.activate()
        try await carTypeRepository.save(carType)
    }

    func deactivate(_ id: UUID) async throws {
        guard let carType = try await load(id) else { throw Abort(.notFound) }

        carType.deactivate()
        try await carTypeRepository.save(carType)
    }
}
