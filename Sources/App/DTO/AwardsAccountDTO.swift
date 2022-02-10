import Vapor

struct AwardsAccountDTO: Content {
    let clientId: UUID
    let date: Date
    let active: Bool
    let translactions: Int

    init(awardsAccount: AwardsAccount) {
        clientId = awardsAccount.$client.id
        date = awardsAccount.date
        active = awardsAccount.isActive
        translactions = awardsAccount.transactions
    }
}
