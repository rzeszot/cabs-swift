import Fluent

struct CreateAddress: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses")
            .id()
            .field("name", .string, .required)
            .field("country", .string, .required)
            .field("district", .string, .required)
            .field("city", .string, .required)
            .field("street", .string, .required)
            .field("building_number", .int, .required)
            .field("additional_number", .int)
            .field("postal_code", .string, .required)

            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses").delete()
    }
}
