import Fluent

struct CreateDriver: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers")
            .id()
            .field("kind", .string, .required)
            .field("status", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("photo", .data)
            .field("driver_license", .string, .required)
            .field("is_occupied", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("drivers").delete()
    }
}
