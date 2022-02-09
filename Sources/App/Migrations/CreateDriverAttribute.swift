import Fluent

struct CreateDriverAttribute: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_attributes")
            .id()
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .field("name", .string, .required)
            .field("value", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_attributes").delete()
    }
}
