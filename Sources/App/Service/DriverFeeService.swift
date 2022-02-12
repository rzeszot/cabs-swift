import Foundation
import Vapor

struct  DriverFeeService {
    let driverFeeRepository: DriverFeeRepository
    let transitRepository: TransitRepository
    
    func calculateDriverFee(transitId: UUID) async throws -> Int {
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }
        
        if let driversFee = transit.driversFee {
            return driversFee
        }
        
        let transitPrice = transit.price
        let driversFee = try await driverFeeRepository.findBy(driver: transit.driver!)

        if driversFee == nil {
            throw DriverFeeNotDefinedError()
        }
        
        let finalFee: Int
        
        if driversFee!.kind == .flat {
            finalFee = transitPrice! - driversFee!.amount
        } else {
            finalFee = transitPrice! * driversFee!.amount / 100
        }
        
        return max(finalFee, driversFee?.min ?? 0)
    }
}

struct DriverFeeNotDefinedError: Error {
}
