import Vapor
import Foundation

struct CannotChangeAddressFromError: Error {
}

struct CannotChangeAddressToError: Error {
}

struct TransitCannotBeCancelledError: Error {
}

struct TransitAlreadyAcceptedError: Error {
}

struct DriverOutOfPossibleDriversError: Error {
}

struct TransitCannotBeStartedError: Error {
}

struct TransitCannotBeCompletedError: Error {
}

struct TransitDoesNotExistError: Error {
}

struct InvalidArgumentError: Error {
}

class TransitService {

    //    private DriverPositionRepository $driverPositionRepository;
    //    private DriverSessionRepository $driverSessionRepository;
    //    private CarTypeService $carTypeService;
    //    private AddressRepository $addressRepository;
    //    private AwardsService $awardsService;
    
    private let driverSessionRepository: DriverSessionRepository
    private let driverPositionRepository: DriverPositionRepository
    private let driverFeeService: DriverFeeService
    private let driverRepository: DriverRepository
    private let clientRepository: ClientRepository
    private let notificationService: DriverNotificationService
    private let addressRepository: AddressRepository
    private let geocodingService: GeocodingService
    private let transitRepository: TransitRepository
    private let distanceCalculator: DistanceCalculator
    private let invoiceGenerator: InvoiceGenerator
    private let carTypeService: CarTypeService
    private let clock: Clock

    init(
        driverSessionRepository: DriverSessionRepository,
        driverPositionRepository: DriverPositionRepository,
        driverRepository: DriverRepository,
        driverFeeService: DriverFeeService,
        clientRepository: ClientRepository,
        notificationService: DriverNotificationService,
        addressRepository: AddressRepository,
        geocodingService: GeocodingService,
        transitRepository: TransitRepository,
        distanceCalculator: DistanceCalculator,
        invoiceGenerator: InvoiceGenerator,
        carTypeService: CarTypeService,
        clock: Clock
    ) {
        self.driverSessionRepository = driverSessionRepository
        self.driverPositionRepository = driverPositionRepository
        self.driverRepository = driverRepository
        self.driverFeeService = driverFeeService
        self.clientRepository = clientRepository
        self.notificationService = notificationService
        self.addressRepository = addressRepository
        self.geocodingService = geocodingService
        self.transitRepository = transitRepository
        self.distanceCalculator = distanceCalculator
        self.invoiceGenerator = invoiceGenerator
        self.carTypeService = carTypeService
        self.clock = clock
    }
    
    func listAll() async throws -> [Transit] {
        try await transitRepository.listAll()
    }

    func createTransit(clientId: UUID, from: Address, to: Address, carClass: String) async throws -> Transit {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }
        
        let transit = Transit()
        
        // FIXME later: add some exceptions handling
        let geoFrom = try await geocodingService.geocodeAddress(address: from)
        let geoTo = try await geocodingService.geocodeAddress(address: to)
        
        transit.$client.id = try client.requireID()
        transit.$from.id = try from.requireID()
        transit.$to.id = try to.requireID()
        transit.carType = carClass
        transit.status = .draft
        transit.dateTime = clock.now()
        
        let distance = distanceCalculator.calculateByMap(latitudeFrom: geoFrom.0, longitudeFrom: geoFrom.1, latitudeTo: geoTo.0, longitudeTo: geoTo.1)
        try transit.setKm(Float(distance))
   
        return try await transitRepository.save(transit)
    }

    func changeTransitAddressFromNew(transitId: UUID, newAddress: Address) async throws {
        try await addressRepository.save(newAddress)
        
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }
        
        // FIXME later: add some exceptions handling
        let geoFromNew = try await geocodingService.geocodeAddress(address: newAddress)
        let geoFromOld = try await geocodingService.geocodeAddress(address: transit.from)
        
        // https://www.geeksforgeeks.org/program-distance-two-points-earth/
        // The math module contains a function
        // named toRadians which converts from
        // degrees to radians.
        let lon1 = deg2rad(geoFromNew.1)
        let lon2 = deg2rad(geoFromOld.1)
        let lat1 = deg2rad(geoFromNew.0)
        let lat2 = deg2rad(geoFromOld.0)
        
        // Haversine formula
        let dlon = lon2 - lon1
        let dlat = lat2 - lat1
        let a = pow(sin(dlat / 2), 2)
                + cos(lat1) * cos(lat2)
                * pow(sin(dlon/2),2)
        
        let c = 2 * asin(sqrt(a))
       
        // Radius of earth in kilometers. Use 3956 for miles
        let r: Double = 6371
        
        // calculate the result
        let distanceInKMeters = c * r

        if !(transit.status == .draft) ||
            (transit.status == .waiting_for_driver_assignment) ||
            (transit.pickupAddressChangeCounter > 2) ||
            (distanceInKMeters > 0.25)
        {
            throw CannotChangeAddressFromError()
        }
        
        transit.from = newAddress
        
        let distance = distanceCalculator.calculateByMap(latitudeFrom: geoFromNew.0, longitudeFrom: geoFromNew.1, latitudeTo: geoFromOld.0, longitudeTo: geoFromOld.1)
        try transit.setKm(Float(distance))
        
        transit.pickupAddressChangeCounter += 1
        _ = try await transitRepository.save(transit)
        
        for driver in transit.proposedDrivers {
            notificationService.notifyAboutChangedTransitAddress(driverId: try driver.requireID(), transitId: transitId)
        }
    }
     
    func changeTransitAddressToNew(transitId: UUID, newAddress: Address) async throws {
        try await addressRepository.save(newAddress)

        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        if transit.status == .completed {
            throw CannotChangeAddressToError()
        }
        
        // FIXME later: add some exceptions handling
        let geoFromNew = try await geocodingService.geocodeAddress(address: transit.from)
        let geoFromOld = try await geocodingService.geocodeAddress(address: newAddress)
        
        transit.to = newAddress
        
        let distance = distanceCalculator.calculateByMap(latitudeFrom: geoFromNew.0, longitudeFrom: geoFromNew.1, latitudeTo: geoFromOld.0, longitudeTo: geoFromOld.1)
        try transit.setKm(Float(distance))
        
        _ = try await transitRepository.save(transit)
        
        if transit.driver != nil {
            notificationService.notifyAboutChangedTransitAddress(driverId: try transit.driver!.requireID(), transitId: transitId)
        }
    }
    
    func cancelTransit(transitId: UUID) async throws {
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        let nonCancellableTransits: [Transit.Status] = [.draft, .waiting_for_driver_assignment, .transit_to_passenger]
        if !nonCancellableTransits.contains(transit.status) {
            throw TransitCannotBeCancelledError()
        }

        transit.status = .cancelled
        transit.driver = nil
        try transit.setKm(0)
        transit.awaitingDriversResponses = 0
        
        _ = try await transitRepository.save(transit)
    
        if transit.driver != nil {
            notificationService.notifyAboutCancelledTransit(driverId: try transit.driver!.requireID(), transitId: transitId)
        }
    }
    
    func publishTransit(transitId: UUID) async throws -> Transit {
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        transit.status = .waiting_for_driver_assignment
        transit.published = clock.now()
        
        _ = try await transitRepository.save(transit)
        
        return transit
    }
    
    // Abandon hope all ye who enter here...
    func findDriversForTransit(transitId: UUID) async throws -> Transit {
        let transit = try await transitRepository.findBy(transitId: transitId)
        
        if let transit = transit {
            if transit.status == .waiting_for_driver_assignment {
                var distanceToCheck = 0

                // Tested on production, works as expected.
                // If you change this code and the system will collapse AGAIN, I'll find you...
                
                while true {
                    if transit.awaitingDriversResponses > 4 {
                        return transit
                    }
                    
                    distanceToCheck += 1
                    
                    // FIXME: to refactor when the final business logic will be determined
                    
                    if transit.published!.addingTimeInterval(300) > clock.now()
                        || distanceToCheck >= 20
                        || transit.status == .cancelled
                    {
                        transit.status = .driver_assignment_failed
                        transit.driver = nil
                        try transit.setKm(0)
                        transit.awaitingDriversResponses = 0
                        
                        return try await transitRepository.save(transit)
                    }
                    
                    let geocoded: (Double, Double)
                    
                    do {
                        geocoded = try await geocodingService.geocodeAddress(address: transit.from)
                    } catch {
                        // Geocoding failed! Ask Jessica or Bryan for some help if needed.
                        geocoded = (0, 0)
                    }
                    
                    let longitude = geocoded.1
                    let latitude = geocoded.0

                    // https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
                    // Earth’s radius, sphere
                    // double R = 6378;
                    let R: Double = 6371 // Changed to 6371 due to Copy&Paste pattern from different source

                    // offsets in meters
                    let dn = Double(distanceToCheck)
                    let de = Double(distanceToCheck)

                    // Coordinate offsets in radians
                    let dLat = dn / R
                    let dLon = de / (R * cos(.pi * latitude / 180))

                    // Offset positions, decimal degrees
                    let latitudeMin = latitude - dLat * 180 / .pi
                    let latitudeMax = latitude + dLat * 180 / .pi
                    let longitudeMin = longitude - dLon * 180 / .pi
                    let longitudeMax = longitude + dLon * 180 / .pi

                    var driversAvgPositions = try await driverPositionRepository
                        .findAverageDriverPositionSince(
                            latitudeMin: latitudeMin,
                            latitudeMax: latitudeMax,
                            longitudeMin: longitudeMin,
                            longitudeMax: longitudeMax,
                            date: clock.now().addingTimeInterval(-5*60)
                        )
                    
                    if driversAvgPositions.count != 0 {
                        driversAvgPositions.sort { a, b in
                            let first = sqrt(pow(latitude - a.latitude, 2) + pow(longitude - a.longitude, 2))
                            let second = sqrt(pow(latitude - b.latitude, 2) + pow(longitude - b.longitude, 2))
                        
                            return first < second
                        }
                        
                        driversAvgPositions = Array(driversAvgPositions.prefix(20))
                        var carClasses: [CarType.CarClass] = []

                        let activeCarClasses = try await carTypeService.findActiveCarClasses()
                        
                        if activeCarClasses.count == 0 {
                            return transit
                        }
                        
                        if let carType = transit.carType.flatMap(CarType.CarClass.init(rawValue:)) {
                            if activeCarClasses.contains(carType) {
                                carClasses.append(carType)
                            } else {
                                return transit
                            }
                        } else {
                            carClasses = activeCarClasses
                        }
                        
                        let drivers = driversAvgPositions.map { $0.driver }
                        
                        let activeDriverIdsInSpecificCar = try await driverSessionRepository
                            .findAllByLoggedOutAtNullAndDriverInAndCarClassIn(drivers: drivers, carClasses: carClasses.map { $0.rawValue })
                        
                        driversAvgPositions = try driversAvgPositions.filter { driver in
                            try activeDriverIdsInSpecificCar.contains { session in
                                try session.driver.requireID() == driver.driver.requireID()
                            }
                        }
                        
                        for driverAvgPosition in driversAvgPositions {
                            let driver = driverAvgPosition.driver
                            
                            if driver.status == .active && driver.isOccupied {
                                if !transit.driversRejections.contains(driver) {
                                    transit.proposedDrivers.append(driver)
                                    transit.awaitingDriversResponses += 1
                                    
                                    notificationService.notifyAboutPossibleTransit(driverId: try driver.requireID(), transitId: transitId)
                                }
                            } else {
                                // Not implemented yet!
                            }
                        }
                        
                        _ = try await transitRepository.save(transit)
                    } else {
                        // Next iteration, no drivers at specified area
                        continue
                    }
                }
            } else {
                throw InvalidArgumentError()
            }
        } else {
            throw TransitDoesNotExistError()
        }
        
        // ain't no easy 🤯
    }
    
    func acceptTransit(driverId: UUID, transitId: UUID) async throws {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }
        
        if transit.driver != nil {
            throw TransitAlreadyAcceptedError()
        }
        
        if transit.driversRejections.contains(driver) {
            throw DriverOutOfPossibleDriversError()
        }
        
        transit.driver = driver
        transit.awaitingDriversResponses = 0
        transit.acceptedAt = clock.now()
        transit.status = . transit_to_passenger
        
        _ = try await transitRepository.save(transit)
        
        driver.isOccupied = true
        _ = try await driverRepository.save(driver)
    }

    func startTransit(driverId: UUID, transitId: UUID) async throws {
        guard let _ = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        if transit.status != .transit_to_passenger {
            throw TransitCannotBeStartedError()
        }
        
        transit.status = .in_transit
        transit.started = Date()
        
        _ = try await transitRepository.save(transit)
    }
    
    func rejectTransit(driverId: UUID, transitId: UUID) async throws {
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        var rejected = transit.driversRejections
        rejected.append(driver)
        transit.driversRejections = rejected
        
        transit.awaitingDriversResponses -= 1
        
        _ = try await transitRepository.save(transit)
    }
    
    func completeTransitFrom(driverId: UUID, transitId: UUID, destinationAddress: Address) async throws {
        _ = try await addressRepository.save(destinationAddress)
        
        guard let driver = try await driverRepository.findBy(id: driverId) else { throw Abort(.notFound) }
        guard let transit = try await transitRepository.findBy(transitId: transitId) else { throw Abort(.notFound) }

        if transit.status == .in_transit {
            // FIXME later: add some exceptions handling
            let geoFrom = try await geocodingService.geocodeAddress(address: transit.from)
            let geoTo = try await geocodingService.geocodeAddress(address: transit.to)
            
            transit.to = destinationAddress
            
            let distance = distanceCalculator.calculateByMap(latitudeFrom: geoFrom.0, longitudeFrom: geoFrom.1, latitudeTo: geoTo.1, longitudeTo: geoTo.1)
            try transit.setKm(Float(distance))
            
            transit.status = .completed
            _ = try transit.calculateFinalCosts()
            driver.isOccupied = false
            transit.completeAt = clock.now()
            
            let driverFee = try await driverFeeService.calculateDriverFee(transitId: transitId)
            transit.driversFee = driverFee
            
            _ = try await driverRepository.save(driver)
            
            // $this->awardsService->registerMiles($transit->getClient()->getId(), $transitId);
            
            _ = try await driverRepository.save(driver)
            _ = try await transitRepository.save(transit)
            
            _ = try await invoiceGenerator.generate(amount: Float(transit.price!), subjectName: transit.client.lastName)
        } else {
            throw TransitCannotBeCompletedError()
        }
    }

}
