import Vapor

struct DriverCreateRequestDTO: Content {
    let license: String
    let lastName: String
    let firstName: String
    let photo: Data?
}

struct DriverResponseDTO: Content {
    let id: UUID
    let firstName: String
    let lastName: String
    let driverLicense: String
    let status: String
    let kind: String
    let photo: Data?

    init(driver: Driver) {
        id = try! driver.requireID()
        firstName = driver.firstName
        lastName = driver.lastName
        driverLicense = driver.driverLicense
        status = driver.status.rawValue
        kind = driver.kind.rawValue
        photo = driver.phoyo
    }
}
