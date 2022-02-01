import Foundation
import Vapor

class ContractService {
    private let contractRepository: ContractRepository

    init(contractRepository: ContractRepository) {
        self.contractRepository = contractRepository
    }

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

}

//
//
//
