import Fluent

struct CreateClient: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("clients")
            .id()
            .field("name", .string, .required)
            .field("last_name", .string, .required)
            .field("type", .string, .required)
            .field("client_type", .string, .required)
            .field("default_payment_type", .string, .required)
            .create()

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("clients").delete()
    }
}
