import Foundation
import Vapor

class ContractService {
    private let contractRepository: ContractRepository
    private let attachmentRepository: ContractAttachmentRepository

    init(contractRepository: ContractRepository, attachmentRepository: ContractAttachmentRepository) {
        self.contractRepository = contractRepository
        self.attachmentRepository = attachmentRepository
    }

    // MARK: -

    func createContract(dto: ContractCreateRequestDTO) async throws -> Contract {
        let count = try await contractRepository.findBy(partnerName: dto.partnerName).count

        let contract = Contract()
        contract.partnerName = dto.partnerName
        contract.subject = dto.subject
        contract.contractNo = "C/\(count + 1)/\(dto.partnerName)"
        contract.creationDate = Date()
        contract.status = .negotiations_in_progress

        return try await contractRepository.save(contract)
    }

    func find(id: UUID) async throws -> Contract? {
        try await contractRepository.findBy(id: id)
    }

    func all() async throws -> [Contract] {
        try await contractRepository.all()
    }

    func acceptContract(id: UUID) async throws {
        guard let contract = try await find(id: id) else { throw Abort(.notFound) }

        // TODO: check if all attachments were accepted by both sides

        contract.status = .accepted
        _ = try await contractRepository.save(contract)
    }

    func rejectContract(id: UUID) async throws {
        guard let contract = try await find(id: id) else { throw Abort(.notFound) }

        contract.status = .rejected
        _ = try await contractRepository.save(contract)
    }

    // MARK: -

    func proposeAttachment(contractId: UUID, contractAttachmentDTO dto: ContractAttachmentPorposalRequestDTO) async throws -> ContractAttachmentResponseDTO {
        guard let contract = try await find(id: contractId) else { throw Abort(.notFound) }

        let attachment = ContractAttachment()
        attachment.creationDate = Date()
        attachment.status = .proposed
        attachment.$contract.id = try contract.requireID()
        attachment.data = dto.data

        _ = try await attachmentRepository.save(attachment)

        return ContractAttachmentResponseDTO(attachment: attachment)
    }

    func rejectAttachment(attachmentId: UUID) async throws {
        guard let attachment = try await attachmentRepository.findBy(id: attachmentId) else { throw Abort(.notFound) }

        attachment.status = .rejected
        _ = try await attachmentRepository.save(attachment)
    }

    func acceptAttachment(attachmentId: UUID) async throws {
        guard let attachment = try await attachmentRepository.findBy(id: attachmentId) else { throw Abort(.notFound) }

        if attachment.status == .accepted_by_one_side || attachment.status == .accepted_by_both_side {
            attachment.status = .accepted_by_both_side
        } else {
            attachment.status = .accepted_by_one_side
        }

        _ = try await attachmentRepository.save(attachment)
    }

    func removeAttachment(contractId: UUID, attachmentId: UUID) async throws {
        // TODO: sprawdzenie czy nalezy do kontraktu (JIRA: II-14455)
        try await attachmentRepository.deleteBy(id: attachmentId)
    }

}
