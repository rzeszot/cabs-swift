import Vapor

struct AddressResponseDTO: Content {
    let name: String
    let city: String
    let street: String
    let buildingNumber: Int
    let country: String

    init(address: Address) {
        name = address.name
        city = address.city
        street = address.street
        buildingNumber = address.buildingNumber
        country = address.country
    }
}
