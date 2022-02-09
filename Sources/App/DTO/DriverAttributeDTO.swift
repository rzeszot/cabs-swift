import Vapor

struct DriverAttributeDTO: Content {
    let name: String
    let value: String

    init(attribute: DriverAttribute) {
        name = attribute.name
        value = attribute.value
    }
}
