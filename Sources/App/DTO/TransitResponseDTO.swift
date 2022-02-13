import Vapor

struct TransitResponseDTO: Content {
    let id: UUID
    let status: String
    let tariff: String
    let kmRate: Double
    let from: AddressResponseDTO
    let to: AddressResponseDTO
    let driver: DriverResponseDTO?
    let client: ClientResponseDTO
    
    // TODO: claim

    init(transit: Transit) {
        id = try! transit.requireID()
        status = transit.status.rawValue
        (tariff, kmRate) = getTariffAndKmRate(transit: transit)
        from = AddressResponseDTO(address: transit.from)
        to = AddressResponseDTO(address: transit.to)
        driver = transit.driver.map(DriverResponseDTO.init(driver:))
        client = ClientResponseDTO(client: transit.client)
    }
}

private func getTariffAndKmRate(transit: Transit) -> (String, Double) {
    let date = Date()
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    
    // wprowadzenie nowych cennikow od 1.01.2019
    if year <= 2018 {
        return ("Standard", 1.00)
    }

    let month = calendar.component(.month, from: date) // n
    let day = calendar.component(.day, from: date) // j
    let hour = calendar.component(.hour, from: date) // G

    // cały ostati dzień roku + pierwszy dzień roku do 6:00
    let isSylwester = (month == 12 && day == 31) || (month == 1 && day == 1 && hour < 6)
    
    if isSylwester { // should of used `leap` for awesomeness
        return ("Sylwester", 3.50)
    } else {
        var weekday = (calendar.component(.weekday, from: date) - calendar.firstWeekday) % 7
        if weekday == 0 { weekday = 7 }
        
        switch weekday {
        case 1, 2, 3, 4:
            return ("Standard", 1.0)
        case 5: // Friday
            if hour < 17 {
                return ("Standard", 1.00)
            } else {
                return ("Weekend+", 2.50)
            }
        case 6: // Saturday
            if hour < 6 || hour >= 17 {
                return ("Weekend+", 2.50)
            } else {
                return ("Weekend", 1.50)
            }
        case 7: // Sunday
            if hour < 6 || hour >= 17 {
                return ("Weekend+", 2.50)
            } else {
                return ("Weekend", 1.50)
            }
        default:
            return ("WTF", 666.00)
        }
        
    }
}

struct TransitCreateRequestDTO: Content {
    let clientId: UUID
    let carClass: String
    let from: AddressCreateDTO
    let to: AddressCreateDTO
    
    struct AddressCreateDTO: Content {
        let country: String
        let district: String
        let city: String
        let street: String
        let buildingNumber: Int
        let additionalNumber: Int?
        let postalCode: String
        let name: String
        
        func toAddress() -> Address {
            let addr = Address()
            addr.country = country
            addr.district = district
            addr.city = city
            addr.street = street
            addr.buildingNumber = buildingNumber
            addr.additionalNumber = additionalNumber
            addr.postalCode = postalCode
            addr.name = name
            
            return addr
        }
    }
}
