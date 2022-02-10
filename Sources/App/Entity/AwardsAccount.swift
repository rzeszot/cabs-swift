import Fluent
import Vapor

class AwardsAccount: Model {

    static let schema = "awards_accounts"

    // MARK: -

    @ID(key: .id)
    var id: UUID?

    @Field(key: "date")
    var date: Date

    @Field(key: "is_active")
    var isActive: Bool

    @Field(key: "transactions")
    var transactions: Int

    @Parent(key: "client_id")
    var client: Client

    // MARK: -

    required init() {
        transactions = 0
    }
}
