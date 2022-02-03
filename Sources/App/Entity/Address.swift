import Fluent
import Vapor

class Address: Model {

    static let schema = "addresses"

    // MARK: -

    @ID(key: .id)
    var id: UUID?

    @Field(key: "country")
    var country: String

    @Field(key: "district")
    var district: String

    @Field(key: "city")
    var city: String

    @Field(key: "street")
    var street: String

    @Field(key: "building_number")
    var buildingNumber: Int

    @OptionalField(key: "additional_number")
    var additionalNumber: Int?

    @Field(key: "postal_code")
    var postalCode: String

    @Field(key: "name")
    var name: String

    // MARK: -

    required init() {

    }
}
