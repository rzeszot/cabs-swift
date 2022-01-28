import Fluent

struct CarTypeRepository {
    let database: Database

    func findBy(id: UUID) async throws -> CarType? {
        try await CarType.find(id, on: database)
    }

    func findBy(carClass: String) async throws -> CarType? {
        try await CarType.query(on: database)
            .filter(\.$carClass == CarType.CarClass(rawValue: carClass)!)
            .first()
    }

    func findBy(status: String) async throws -> [CarType] {
        try await CarType.query(on: database)
            .filter(\.$status == CarType.Status(rawValue: status)!)
            .all()
    }

    func save(_ carType: CarType) async throws {
        try await carType.save(on: database)
    }

    func delete(_ carType: CarType) async throws {
        try await carType.delete(on: database)
    }

    func all() async throws -> [CarType] {
        try await CarType.query(on: database)
            .all()
    }
}
