import Fluent

struct CreateCarType: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("car_types")
            .id()
            .field("car_class", .string, .required)
            .field("description", .string, .required)
            .field("status", .string, .required)
            .field("cars_counter", .int, .required)
            .field("min_no_of_cars_to_activate_class", .int, .required)
            .field("active_cars_counter", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("car_types").delete()
    }
}
