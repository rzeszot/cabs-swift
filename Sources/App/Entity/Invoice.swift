import Fluent
import Vapor

class Invoice: Model {
    static let schema = "invoices"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "amount")
    var amount: Float

    @Field(key: "subject_name")
    var subjectName: String

    required init() {

    }
}
