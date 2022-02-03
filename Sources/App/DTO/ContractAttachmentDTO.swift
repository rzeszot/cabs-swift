import Vapor

struct ContractAttachmentPorposalRequestDTO: Content {
    let data: Data
}

struct ContractAttachmentResponseDTO: Content {
    let id: UUID
    let status: String
    let data: Data
    let creationDate: Date
    let acceptedAt: Date?
    let rejectedAt: Date?
    let changeDate: Date?

    init(attachment: ContractAttachment) {
        id = try! attachment.requireID()
        status = attachment.status.rawValue
        data = attachment.data
        creationDate = attachment.creationDate
        acceptedAt = attachment.acceptedAt
        rejectedAt = attachment.rejectedAt
        changeDate = attachment.changeDate
    }
}
