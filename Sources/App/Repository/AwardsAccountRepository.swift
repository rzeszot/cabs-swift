import Foundation
import Fluent

struct AwardsAccountRepository {
    let database: Database

    func save(_ awardsAccount: AwardsAccount) async throws -> AwardsAccount {
        try await awardsAccount.save(on: database)
        return awardsAccount
    }

    func findBy(client: Client) async throws -> AwardsAccount? {
        let clientId = try client.requireID()

        return try await AwardsAccount.query(on: database)
            .filter(\.$client.$id == clientId)
            .first()
    }

}
