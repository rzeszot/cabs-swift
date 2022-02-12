import Fluent

struct CreateTransit: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("transits")
            .id()
            .field("driver_payment_status", .string)
            .field("client_payment_status", .string)
            .field("payment_type", .string)
            .field("status", .string, .required)
            .field("date", .datetime)
            .field("from_address_id", .uuid, .required, .references("addresses", "id"))
            .field("to_address_id", .uuid, .required, .references("addresses", "id"))
            .field("pickup_address_change_counter", .int, .required)
            .field("driver_id", .uuid, .references("drivers", "id"))
            .field("accepted_at", .datetime)
            .field("started", .datetime)
            .field("complete_at", .datetime)
            .field("awaiting_drivers_responses", .int, .required)
            .field("factor", .int)
            .field("km", .float)
            .field("price", .int)
            .field("estimated_price", .int)
            .field("drivers_fee", .int)
            .field("date_time", .datetime)
            .field("published", .datetime)
            .field("client_id", .uuid, .required, .references("clients", "id"))
            .field("car_type", .string)
            .create()
        
        try await database.schema("transits+proposed")
            .id()
            .field("transit_id", .uuid, .required, .references("transits", "id"))
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .create()

        try await database.schema("transits+rejected")
            .id()
            .field("transit_id", .uuid, .required, .references("transits", "id"))
            .field("driver_id", .uuid, .required, .references("drivers", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("transits+proposed").delete()
        try await database.schema("transits+rejected").delete()
        try await database.schema("transits").delete()
    }
}
