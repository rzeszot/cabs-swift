import Fluent
import Vapor

class DriverFee: Model {
    enum Kind: String, Codable {
        case flat
        case percentage
    }

    // MARK: -

    static let schema = "drivers_fees"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "kind")
    var kind: Kind

    @Field(key: "amount")
    var amount: Int

    @OptionalField(key: "min")
    var min: Int?

    @Parent(key: "driver_id")
    var driver: Driver

    required init() {

    }

}
