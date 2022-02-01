import Foundation
import Fluent
import Vapor

struct ContractController: RouteCollection {
    let contractService: ContractService

    func boot(routes: RoutesBuilder) throws {
        routes.group("contracts") { contracts in
            contracts.get(use: list)
            contracts.post(use: create)

            contracts.group(":id") { contract in
                contract.get(use: find)
                contract.post("accept", use: accept)
                contract.post("reject", use: reject)
            }
        }
    }

    // MARK: -

    func create(request: Request) async throws-> ContractResponseDTO {
        let dto = try request.content.decode(ContractCreateRequestDTO.self)
        let created = try await contractService.createContract(dto: dto)
        return ContractResponseDTO(contract: created)
    }

    func list(request: Request) async throws -> [ContractResponseDTO] {
        return try await contractService.all().map(ContractResponseDTO.init(contract:))
    }

    func find(request: Request) async throws -> ContractResponseDTO {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }

        if let contract = try await contractService.find(id: id) {
            return ContractResponseDTO(contract: contract)
        } else {
            throw Abort(.notFound)
        }
    }

    // MARK: -

    func accept(request: Request) async throws -> String {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        try await contractService.acceptContract(id: id)
        return "{}"
    }

    func reject(request: Request) async throws -> String {
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        try await contractService.rejectContract(id: id)
        return "{}"
    }

}

