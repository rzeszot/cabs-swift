import Vapor

struct CarTypeRequestDTO: Content {
    let carClass: String
    let description: String
    let minNoOfCarsToActivateClass: Int
}

struct CarTypeResponseDTO: Content {
    let id: UUID
    let carClass: String
    let description: String
    let status: String
    let carsCounter: Int
    let minNoOfCarsToActivateClass: Int
    let activeCarsCounter: Int

    init(_ carType: CarType) {
        id = try! carType.requireID()
        carClass = carType.carClass.rawValue
        description = carType.description
        status = carType.status.rawValue
        carsCounter = carType.carsCounter
        minNoOfCarsToActivateClass = carType.minNoOfCarsToActivateClass
        activeCarsCounter = carType.activeCarsCounter
    }
}
