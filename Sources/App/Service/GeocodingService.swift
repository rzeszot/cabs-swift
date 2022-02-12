import Foundation

class GeocodingService {

    func geocodeAddress(address: Address) async throws -> (Double, Double) {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                continuation.resume(returning: (1, 1))
            }
        }
    }

}
