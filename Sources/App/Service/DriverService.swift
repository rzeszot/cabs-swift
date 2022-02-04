import Foundation
import Vapor

struct IllegalLicenseError: Error {
    let license: String
}

struct CannotChangeLicenseError: Error {

}

class DriverService {
    let driver_license_regexp = try! NSRegularExpression(pattern: "/^[A-Z9]{5}[0-9]{6}[A-Z9]{2}[0-9][A-Z]{2}$/")

    private let driverRepository: DriverRepository

    init(driverRepository: DriverRepository) {
        self.driverRepository = driverRepository
    }

    // MARK: -

    func createDriver(license: String, lastName: String, firstName: String, kind: Driver.Kind, status: Driver.Status, photo: Data?) async throws -> Driver {
        let driver = Driver()
        if status == .active {
            if license.isEmpty {
                throw IllegalLicenseError(license: license)
            }

            let result = driver_license_regexp.matches(in: license, options: [], range: NSRange(location: 0, length: license.count))

            if result.isEmpty {
                throw IllegalLicenseError(license: license)
            }
        }

        driver.driverLicense = license
        driver.lastName = lastName
        driver.firstName = firstName
        driver.kind = kind
        driver.status = status
        driver.phoyo = photo
        driver.isOccupied = false

        return try await driverRepository.save(driver)
    }

    func changeLicenseNumber(newLicense: String, driverId: UUID) async throws {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }

        if newLicense.isEmpty {
            throw IllegalLicenseError(license: newLicense)
        }

        let result = driver_license_regexp.matches(in: newLicense, options: [], range: NSRange(location: 0, length: newLicense.count))

        if result.isEmpty {
            throw IllegalLicenseError(license: newLicense)
        }

        if driver.status != .active {
            throw CannotChangeLicenseError()
        }

        driver.driverLicense = newLicense
        _ = try await driverRepository.save(driver)
    }

    func changeDriverStatus(driverId: UUID, status: Driver.Status) async throws -> Driver {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }

        if status == .active {
            if driver.driverLicense.isEmpty {
                throw IllegalLicenseError(license: driver.driverLicense)
            }

            let result = driver_license_regexp.matches(in: driver.driverLicense, options: [], range: NSRange(location: 0, length: driver.driverLicense.count))

            if result.isEmpty {
                throw IllegalLicenseError(license: driver.driverLicense)
            }
        }

        driver.status = status

        return try await driverRepository.save(driver)
    }

    func chagePhoto(driverId: UUID, photo: Data?) async throws {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }

        driver.phoyo = photo
        _ = try await driverRepository.save(driver)
    }

    func load(driverId: UUID) async throws -> Driver? {
        try await driverRepository.findBy(id: driverId)
    }

    func allDrivers() async throws -> [Driver] {
        try await driverRepository.all()
    }

}

