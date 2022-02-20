import Foundation

class DriverNotificationService {

    func notifyAboutPossibleTransit(driverId: UUID, transitId: UUID) {
        print("notify \(driverId) about possible transit \(transitId)")
    }

    func notifyAboutChangedTransitAddress(driverId: UUID, transitId: UUID) {
        print("notify \(driverId) about changed address in transit \(transitId)")

    }
    
    func notifyAboutCancelledTransit(driverId: UUID, transitId: UUID) {
        print("notify \(driverId) about cancelled transit \(transitId)")
    }
    
    func askDriverForDetailsAboutClaim(claimNo: String, driverId: UUID) {
        print("notify \(driverId) about claim \(claimNo)")
    }

}

