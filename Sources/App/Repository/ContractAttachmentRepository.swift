import Foundation
import Fluent

struct ContractAttachmentRepository {
    let database: Database

    func save(_ attachment: ContractAttachment) async throws -> ContractAttachment {
        try await attachment.save(on: database)
        try await attachment.$contract.load(on: database)

        return attachment
    }

    func deleteBy(id: UUID) async throws {
        try await ContractAttachment.find(id, on: database)?.delete(on: database)
    }

    func findBy(id: UUID) async throws -> ContractAttachment? {
        try await ContractAttachment.find(id, on: database)
    }

    func findBy(contract: Contract)  async throws -> [ContractAttachment] {
        let contractId = try contract.requireID()

        return try await ContractAttachment.query(on: database)
            .filter(\.$contract.$id == contractId)
            .all()
    }
}
