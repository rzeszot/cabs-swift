import Fluent
import Vapor

class DriverPosition: Model, Equatable {
    static let schema = "drivers_positions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "driver")
    var driver: Driver

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "seen_at")
    var seenAt: Date

    required init() {

    }

    static func == (lhs: DriverPosition, rhs: DriverPosition) -> Bool {
        try! lhs.requireID() == rhs.requireID()
    }
}
