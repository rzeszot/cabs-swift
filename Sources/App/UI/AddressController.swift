import Foundation
import Fluent
import Vapor

struct AddressController: RouteCollection {
    let addressRepository: AddressRepository

    func boot(routes: RoutesBuilder) throws {
        routes.group("addresses") { addresses in
            addresses.get(use: listAllAddresses)
        }
    }

    // MARK: -

    func listAllAddresses(request: Request) async throws -> [AddressResponseDTO] {
        let addresses = try await addressRepository.listAll()
        return addresses.map(AddressResponseDTO.init(address:))
    }

}
