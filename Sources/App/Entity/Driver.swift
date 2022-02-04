import Fluent
import Vapor

class Driver: Model {
    enum Kind: String, Codable {
        case candidate
        case regular
    }

    enum Status: String, Codable {
        case active
        case inactive
    }

    // MARK: -

    static let schema = "drivers"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "kind")
    var kind: Kind

    @Field(key: "status")
    var status: Status

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @OptionalField(key: "photo")
    var phoyo: Data?

    @Field(key: "driver_license")
    var driverLicense: String

    @OptionalChild(for: \.$driver)
    var fee: DriverFee?

    @Field(key: "is_occupied")
    var isOccupied: Bool

    required init() {

    }

}

