import Fluent
import Vapor

struct CompletedTransitError: Error {

}

struct TransitNotCompletedError: Error {

}

class Transit: Model {
    enum Status: String, Codable {
        case draft
        case cancelled
        case waiting_for_driver_assignment
        case driver_assignment_failed
        case transit_to_passenger
        case in_transit
        case completed
    }
    
    enum DriverPaymentStatus: String, Codable {
        case not_paid
        case paid
        case claimed
        case returned
    }

    enum ClientPaymentStatus: String, Codable {
        case not_paid
        case paid
        case returned
    }
    
    static let baseFee: Double = 8.0
    
    static let schema = "transits"

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "driver_payment_status")
    var driverPaymentStatus: DriverPaymentStatus?
    
    @OptionalField(key: "client_payment_status")
    var clientPaymentStatus: ClientPaymentStatus?
    
    @OptionalField(key: "payment_type")
    var paymentKind: Client.PaymentKind?
    
    @Field(key: "status")
    var status: Status
    
    @OptionalField(key: "date")
    var date: Date?
    
    @Parent(key: "from_address_id")
    var from: Address
    
    @Parent(key: "to_address_id")
    var to: Address

    @Field(key: "pickup_address_change_counter")
    var pickupAddressChangeCounter: Int
    
    @OptionalParent(key: "driver_id")
    var driver: Driver?
    
    @OptionalField(key: "accepted_at")
    var acceptedAt: Date?
    
    @OptionalField(key: "started")
    var started: Date?
    
    @OptionalField(key: "complete_at")
    var completeAt: Date?
    
    @Siblings(through: RejectedDriver.self, from: \.$transit, to: \.$driver)
    var driversRejections: [Driver]

    @Siblings(through: ProposedDriver.self, from: \.$transit, to: \.$driver)
    var proposedDrivers: [Driver]

    @Field(key: "awaiting_drivers_responses")
    var awaitingDriversResponses: Int
    
    @OptionalField(key: "factor")
    var factor: Int?

    @OptionalField(key: "km")
    private(set) var km: Float?
    
    func setKm(_ km: Float) throws {
        self.km = km
        _ = try estimateCost()
    }

    // https://stackoverflow.com/questions/37107123/sould-i-store-price-as-decimal-or-integer-in-mysql
    @OptionalField(key: "price")
    var price: Int?
    
    @OptionalField(key: "estimated_price")
    var estimatedPrice: Int?

    @OptionalField(key: "drivers_fee")
    var driversFee: Int?
    
    @OptionalField(key: "date_time")
    var dateTime: Date?
    
    @OptionalField(key: "published")
    var published: Date?
    
    @Parent(key: "client_id")
    var client: Client
    
    @OptionalField(key: "car_type")
    var carType: String?
    
    required init() {

    }
    
    func estimateCost() throws -> Int {
        if status == .completed {
            throw CompletedTransitError()
        }
        
        let estimated = calculateCost()
        estimatedPrice = estimated
        price = nil
        
        return estimated
    }
    
    func calculateFinalCosts() throws -> Int {
        if status == .completed {
            return calculateCost()
        } else {
            throw TransitNotCompletedError()
        }
    }
    
    private func calculateCost() -> Int {
        var baseFee = Self.baseFee
        let factorToCalculate = factor ?? 1

        let kmRate: Double
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: dateTime!)
        
        // wprowadzenie nowych cennikow od 1.01.2019
        if year <= 2018 {
            kmRate = 1.0
            baseFee += 1
        } else {
            let month = calendar.component(.month, from: dateTime!) // n
            let day = calendar.component(.day, from: dateTime!) // j
            let hour = calendar.component(.hour, from: dateTime!) // G
            var weekday = (calendar.component(.weekday, from: dateTime!) - calendar.firstWeekday) % 7

            if weekday == 0 {
                weekday = 7
            }

            if (month == 12 && day == 31) || (month == 1 && day == 1 && hour <= 6) {
                kmRate = 2.50
                baseFee += 3
            } else {
                // piątek i sobota po 17 do 6 następnego dnia
                if (weekday == 5 && hour >= 16) || (weekday == 6 && hour <= 6) || (weekday == 6 && hour >= 17) || (weekday == 7 && hour <= 6) {
                    kmRate = 2.50
                    baseFee += 2
                } else {
                    // pozostałe godziny weekendu
                    if (weekday == 6 && hour > 6 && hour < 17) || (weekday == 7 && hour > 6) {
                        kmRate = 1.5
                    } else {
                        // tydzień roboczy
                        kmRate = 1.0
                        baseFee += 1
                    }
                }
            }
        }

        let finalPrice = Int(ceil((Double(km!) * kmRate * Double(factorToCalculate) + baseFee) * 100))
        price = finalPrice
        return finalPrice
    }

    class RejectedDriver: Model {
        static let schema = "transits+rejected"

        @ID(key: .id)
        var id: UUID?
        
        @Parent(key: "transit_id")
        var transit: Transit

        @Parent(key: "driver_id")
        var driver: Driver
        
        required init() {
    
        }
    
        init(id: UUID? = nil, transit: Transit, driver: Driver) throws {
            self.id = id
            self.$transit.id = try transit.requireID()
            self.$driver.id = try driver.requireID()
        }
    }
    
    class ProposedDriver: Model {
        static let schema = "transits+proposed"

        @ID(key: .id)
        var id: UUID?
        
        @Parent(key: "transit_id")
        var transit: Transit

        @Parent(key: "driver_id")
        var driver: Driver
        
        required init() {
    
        }
        
        init(id: UUID? = nil, transit: Transit, driver: Driver) throws {
            self.id = id
            self.$transit.id = try transit.requireID()
            self.$driver.id = try driver.requireID()
        }
    }
}
