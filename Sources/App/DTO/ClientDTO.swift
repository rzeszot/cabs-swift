import Vapor

struct ClientRegisterRequestDTO: Content {
    let name: String
    let lastName: String
    let type: String
    let defaultPaymentType: String
}

struct ClientChangeDefaultPaymentTypeRequestDTO: Content {
    let defaultPaymentType: String
}

struct ClientResponseDTO: Content {
    let id: UUID
    let name: String
    let lastName: String
    let type: String
    let defaultPaymentType: String
    let clientType: String

    init(client: Client) {
        id = try! client.requireID()
        name = client.name
        lastName = client.lastName
        type = client.kind.rawValue
        defaultPaymentType = client.defaultPaymentKind.rawValue
        clientType = client.clientKind.rawValue
    }
}
