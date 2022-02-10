import Vapor
import Foundation

class InvoiceGenerator {

    private let invoiceRepository: InvoiceRepository

    init(
        invoiceRepository: InvoiceRepository
    ) {
        self.invoiceRepository = invoiceRepository
    }

    func generate(amount: Float, subjectName: String) async throws -> Invoice {
        let invoice = Invoice()
        invoice.subjectName = subjectName
        invoice.amount = amount

        return try await invoiceRepository.save(invoice)
    }

}
