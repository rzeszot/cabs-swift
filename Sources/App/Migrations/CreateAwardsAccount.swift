import Fluent

struct CreateAwardsAccount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("awards_accounts")
            .id()
            .field("client_id", .uuid, .required, .references("clients", "id"))
            .field("date", .date, .required)
            .field("is_active", .bool, .required)
            .field("transactions", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("awards_accounts").delete()
    }
}
