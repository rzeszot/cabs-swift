import Fluent

struct CreateContractAttachment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contracts_attachments")
            .id()
            .field("contract_id", .uuid, .required, .references("contracts", "id"))
            .field("status", .string, .required)
            .field("data", .data, .required)
            .field("creation_date", .datetime, .required)
            .field("accepted_at", .datetime)
            .field("rejected_at", .datetime)
            .field("change_date", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contracts_attachments").delete()
    }
}
