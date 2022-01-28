import Fluent
import Vapor

class CarType: Model {
    enum Status: String, Codable {
        case inactive
        case active
    }

    enum CarClass: String, Codable {
        case eco
        case regular
        case van
        case premium
    }

    // MARK: -

    static let schema = "car_types"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "car_class")
    var carClass: CarClass

    @Field(key: "description")
    var description: String

    @Field(key: "status")
    private(set) var status: Status

    @Field(key: "cars_counter")
    private(set) var carsCounter: Int

    @Field(key: "min_no_of_cars_to_activate_class")
    private(set) var minNoOfCarsToActivateClass: Int

    @Field(key: "active_cars_counter")
    private(set) var activeCarsCounter: Int

    // MARK: -

    init(carClass: CarClass, description: String, minNoOfCarsToActivateClass: Int) {
        self.carClass = carClass
        self.description = description
        self.minNoOfCarsToActivateClass = minNoOfCarsToActivateClass

        self.status = .inactive
        self.carsCounter = 0
        self.activeCarsCounter = 0
    }

    required init() {

    }

    // MARK: -

    func registerActiveCar() {
        activeCarsCounter += 1
    }

    func unregisterActiveCar() {
        activeCarsCounter -= 1
    }

    func registerCar() {
        carsCounter += 1
    }

    func unregisterCar() throws {
        carsCounter -= 1

        if carsCounter < 0 {
            throw InvalidCarsNumberError()
        }
    }

    func activate() throws {
        if carsCounter < minNoOfCarsToActivateClass {
            throw CannotActivateCarClassError()
        }

        status = .active
    }

    func deactivate() {
        status = .inactive
    }

    struct InvalidCarsNumberError: Error {}
    struct CannotActivateCarClassError: Error {}
}
