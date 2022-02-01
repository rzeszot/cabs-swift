import Fluent

struct CreateContract: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contracts")
            .id()
            .field("contract_no", .string, .required)
            .field("partner_name", .string, .required)
            .field("status", .string, .required)
            .field("subject", .string, .required)
            .field("creation_date", .datetime, .required)
            .field("accepted_at", .datetime)
            .field("rejected_at", .datetime)
            .field("change_date", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contracts").delete()
    }
}
