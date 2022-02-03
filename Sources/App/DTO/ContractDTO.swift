import Vapor

struct ContractCreateRequestDTO: Content {
    let partnerName: String
    let subject: String
}

struct ContractResponseDTO: Content {
    let id: String
    let contract_no: String
    let partner_name: String
    let status: String
    let subject: String
    let creation_date: Date
    let accepted_at: Date?
    let rejected_at: Date?
    let change_date: Date?
    let attachments: [ContractAttachmentResponseDTO]

    init(contract: Contract) {
        id = try! contract.requireID().uuidString
        contract_no = contract.contractNo
        partner_name = contract.partnerName
        status = contract.status.rawValue
        subject = contract.subject
        creation_date = contract.creationDate
        accepted_at = contract.acceptedAt
        rejected_at = contract.rejectedAt
        change_date = contract.changeDate
        attachments = contract.attachments.map(ContractAttachmentResponseDTO.init(attachment:))
    }
}
