import Foundation
import Fluent

struct ClientRepository {
    let database: Database

    func save(_ client: Client) async throws -> Client {
        try await client.save(on: database)
        return client
    }

    func findBy(id: UUID) async throws -> Client? {
        try await Client.query(on: database)
            .filter(\.$id == id)
            .first()
    }

    func all() async throws -> [Client] {
        try await Client.query(on: database)
            .all()
    }

}
