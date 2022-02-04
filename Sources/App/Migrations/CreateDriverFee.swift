import Fluent

struct CreateDriverFee: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_fees")
            .id()
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .field("kind", .string, .required)
            .field("amount", .int, .required)
            .field("min", .int)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_fees").delete()
    }
}
