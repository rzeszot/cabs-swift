import Fluent
import Vapor

class DriverSession: Model {
    static let schema = "drivers_sessions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "plates_number")
    var platesNumber: String

    @Field(key: "car_class")
    var carClass: String

    @Field(key: "car_brand")
    var carBrand: String

    @Parent(key: "driver_id")
    var driver: Driver

    @Field(key: "logged_at")
    var loggedAt: Date

    @OptionalField(key: "logged_out_at")
    var loggedOutAt: Date?

    required init() {

    }
}
