import Vapor

struct AddressResponseDTO: Content {
    let id: UUID
    let name: String
    let city: String
    let street: String
    let buildingNumber: Int
    let country: String

    init(address: Address) {
        id = try! address.requireID()
        name = address.name
        city = address.city
        street = address.street
        buildingNumber = address.buildingNumber
        country = address.country
    }
}

struct AddressCreateDTO: Content {
    let country: String
    let district: String
    let city: String
    let street: String
    let buildingNumber: Int
    let additionalNumber: Int?
    let postalCode: String
    let name: String

    func toAddress() -> Address {
        let addr = Address()
        addr.country = country
        addr.district = district
        addr.city = city
        addr.street = street
        addr.buildingNumber = buildingNumber
        addr.additionalNumber = additionalNumber
        addr.postalCode = postalCode
        addr.name = name

        return addr
    }
}
