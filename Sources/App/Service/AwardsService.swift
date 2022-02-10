
import Foundation

protocol AwardsService {
    func findBy(clientId: UUID) async throws -> AwardsAccountDTO
    func registerToProgram(clientId: UUID) async throws
    func activateAccount(clientId: UUID) async throws
    func deactivateAccount(clientId: UUID) async throws
//    func registerMiles(clientId: UUID, miles: Int) async throws -> AwardedMiles?
//    func registerSpecialMiles(clientId: UUID, miles: Int) async throws -> AwardedMiles
//    func removeMiles(clientId: UUID, miles: Int) async throws
//    func calculateBalance(clientId: UUID) async throws -> Int
//    func transferMiles(from fromClientId: UUID, to toClientId: UUID, miles: Int) async throws
}
