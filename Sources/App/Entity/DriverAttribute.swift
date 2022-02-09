import Vapor
import Fluent

class DriverAttribute: Model {
    enum Name: String {
        case penalty_points
        case nationality
        case years_of_experience
        case medical_examination_expiration_date
        case medical_examination_remarks
        case email
        case birthplace
        case company_name
    }

    static let schema = "drivers_attributes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "value")
    var value: String

    @Parent(key: "driver_id")
    var driver: Driver

    required init() {
        
    }
}
