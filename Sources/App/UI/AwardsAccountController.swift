import Foundation
import Fluent
import Vapor

struct AwardsAccountController: RouteCollection {
    let awardsService: AwardsService

    func boot(routes: RoutesBuilder) throws {
        routes.group("clients") { clients in
            clients.group(":client_id") { client in
                client.group("awards") { awards in
                    awards.get(use: all)
                    awards.post(use: registerToProgram)
                    awards.post("activate", use: activate)
                    awards.post("deactivate", use: deactivate)
                }
            }
        }
    }

    // MARK: -

    func registerToProgram(request: Request) async throws -> AwardsAccountDTO {
        guard let clientId = request.parameters.get("client_id", as: UUID.self) else { throw Abort(.badRequest) }

        try await awardsService.registerToProgram(clientId: clientId)
        let account = try await awardsService.findBy(clientId: clientId)

        return account
    }

    func activate(request: Request) async throws -> AwardsAccountDTO {
        guard let clientId = request.parameters.get("client_id", as: UUID.self) else { throw Abort(.badRequest) }

        try await awardsService.activateAccount(clientId: clientId)
        let account = try await awardsService.findBy(clientId: clientId)

        return account
    }

    func deactivate(request: Request) async throws -> AwardsAccountDTO {
        guard let clientId = request.parameters.get("client_id", as: UUID.self) else { throw Abort(.badRequest) }

        try await awardsService.deactivateAccount(clientId: clientId)
        let account = try await awardsService.findBy(clientId: clientId)

        return account
    }

    func all(request: Request) async throws -> AwardsAccountDTO {
        guard let clientId = request.parameters.get("client_id", as: UUID.self) else { throw Abort(.badRequest) }

        let account = try await awardsService.findBy(clientId: clientId)

        return account
    }
}

//
//    #[Route('/clients/{clientId}/awards/balance', methods: ['GET'])]
//    public function balance(int $clientId): Response
//    {
//        return new JsonResponse($this->awardsService->calculateBalance($clientId));
//    }
//
//    #[Route('/clients/{clientId}/awards/transfer/{toClientId}/{howMuch}', methods: ['POST'])]
//    public function transferMiles(int $clientId, int $toClientId, int $howMuch): Response
//    {
//        $this->awardsService->transferMiles($clientId, $toClientId, $howMuch);
//        return new JsonResponse($this->awardsService->findBy($clientId));
//    }
