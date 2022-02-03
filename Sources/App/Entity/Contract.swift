import Fluent
import Vapor

class Contract: Model {
    enum Status: String, Codable {
        case negotiations_in_progress
        case rejected
        case accepted
    }

    // MARK: -

    static let schema = "contracts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "contract_no")
    var contractNo: String

    @Field(key: "partner_name")
    var partnerName: String

    @Field(key: "status")
    var status: Status // = .negotiations_in_progress

    @Field(key: "subject")
    var subject: String

    @Field(key: "creation_date")
    var creationDate: Date // = .now

    @OptionalField(key: "accepted_at")
    var acceptedAt: Date?

    @OptionalField(key: "rejected_at")
    var rejectedAt: Date?

    @OptionalField(key: "change_date")
    var changeDate: Date?

    @Children(for: \.$contract)
    var attachments: [ContractAttachment]

    required init() {

    }

}
