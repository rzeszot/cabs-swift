import Fluent

struct CreateDriverSession: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_sessions")
            .id()
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .field("plates_number", .string, .required)
            .field("car_class", .string, .required)
            .field("car_brand", .string, .required)
            .field("logged_at", .datetime, .required)
            .field("logged_out_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers_sessions").delete()
    }
}
