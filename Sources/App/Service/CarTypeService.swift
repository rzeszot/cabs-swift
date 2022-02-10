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

    func registerActiveCar(carClass: String) async throws {
        guard let carType = try await findBy(carClass: carClass) else { throw Abort(.notFound) }
        carType.registerCar()
        return try await carTypeRepository.save(carType)
    }

    func unregisterActiveCar(carClass: String) async throws {
        guard let carType = try await findBy(carClass: carClass) else { throw Abort(.notFound) }
        carType.unregisterActiveCar()
        return try await carTypeRepository.save(carType)
    }

    private func findBy(carClass: String) async throws -> CarType? {
        try await carTypeRepository.findBy(carClass: carClass)
    }

}
//
//    public function findActiveCarClasses(): array
//    {
//        return array_map(fn(CarType $carType) => $carType->getCarClass(), $this->carTypeRepository->findByStatus(CarType::STATUS_ACTIVE));
//    }
//
//    public function getMinNumberOfCars(string $carClass): int
//    {
//        if($carClass === CarType::CAR_CLASS_ECO) {
//            return $this->appProperties->getMinNoOfCarsForEcoClass();
//        } else {
//            return 10;
//        }
//    }
//
//    public function removeCarType(string $carClass): void
//    {
//        $carType = $this->carTypeRepository->findByCarClass($carClass);
//        if($carType !== null) {
//            $this->carTypeRepository->delete($carType);
//        }
//    }
