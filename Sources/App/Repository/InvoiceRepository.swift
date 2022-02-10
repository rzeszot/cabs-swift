import Foundation
import Fluent

struct InvoiceRepository {
    let database: Database

    func save(_ invoice: Invoice) async throws -> Invoice {
        try await invoice.save(on: database)
        return invoice
    }

}
