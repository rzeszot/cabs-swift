import Fluent

struct CreateInvoice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("invoices")
            .id()
            .field("amount", .float, .required)
            .field("subject_name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("invoices").delete()
    }
}
