import Foundation

final class SystemClock: Clock {
    func now() -> Date {
        return Date()
    }
}
