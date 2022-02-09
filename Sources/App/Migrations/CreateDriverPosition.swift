import Fluent

struct CreateDriverPosition: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_positions")
            .id()
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("seen_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_positions").delete()
    }
}
