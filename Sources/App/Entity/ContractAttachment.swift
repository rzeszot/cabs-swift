import Fluent
import Vapor

class ContractAttachment: Model {
    enum Status: String, Codable {
        case proposed
        case accepted_by_one_side
        case accepted_by_both_side
        case rejected
    }

    // MARK: -

    static let schema = "contracts_attachments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: Status // = .proposed

    @Parent(key: "contract_id")
    var contract: Contract

    @Field(key: "data")
    var data: Data

    @Field(key: "creation_date")
    var creationDate: Date

    @OptionalField(key: "accepted_at")
    var acceptedAt: Date?

    @OptionalField(key: "rejected_at")
    var rejectedAt: Date?

    @OptionalField(key: "change_date")
    var changeDate: Date?

    required init() {

    }

}
