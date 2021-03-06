import Fluent
import Vapor

func routes(_ app: Application) throws {
    let appProperties = AppProperties()
    let clock = SystemClock()

    let carTypeRepository = CarTypeRepository(database: app.db)
    let carTypeService = CarTypeService(carTypeRepository: carTypeRepository, appProperties: appProperties)

    let clientRepository = ClientRepository(database: app.db)
    let clientService = ClientService(clientRepository: clientRepository)

    let contractRepository = ContractRepository(database: app.db)
    let attachmentRepository = ContractAttachmentRepository(database: app.db)
    let contractService = ContractService(contractRepository: contractRepository, attachmentRepository: attachmentRepository)

    let driverRepository = DriverRepository(database: app.db)
    let driverAttributeRepository = DriverAttributeRepository(database: app.db)
    let driverService = DriverService(driverRepository: driverRepository, driverAttributeRepository: driverAttributeRepository)

    let driverPositionRepository = DriverPositionRepository(database: app.db)
    let distanceCalculator = DistanceCalculator()
    let trackingService = DriverTrackingService(
        positionRepository: driverPositionRepository,
        driverRepository: driverRepository,
        distanceCalculator: distanceCalculator,
        clock: clock
    )

    let driverSessionRepository = DriverSessionRepository(database: app.db)
    let driverSessionService = DriverSessionService(
        driverRepository: driverRepository,
        carTypeService: carTypeService,
        driverSessionRepository: driverSessionRepository,
        clock: clock
    )
    
    let transitRepository = TransitRepository(database: app.db)
    let driverFeeRepository = DriverFeeRepository(database: app.db)
    let driverFeeService = DriverFeeService(
        driverFeeRepository: driverFeeRepository,
        transitRepository: transitRepository
    )
    let driverNotificationService = DriverNotificationService()
    let addressRepository = AddressRepository(database: app.db)
    let geocodingService = GeocodingService()
    let invoiceRepository = InvoiceRepository(database: app.db)
    let invoiceGenerator = InvoiceGenerator(invoiceRepository: invoiceRepository)
    let transitService = TransitService(
        driverSessionRepository: driverSessionRepository,
        driverPositionRepository: driverPositionRepository,
        driverRepository: driverRepository,
        driverFeeService: driverFeeService,
        clientRepository: clientRepository,
        notificationService: driverNotificationService,
        addressRepository: addressRepository,
        geocodingService: geocodingService,
        transitRepository: transitRepository,
        distanceCalculator: distanceCalculator,
        invoiceGenerator: invoiceGenerator,
        carTypeService: carTypeService,
        clock: clock
    )

    app.get { req -> String in
        return "cabs-swift"
    }

    try app.register(collection: CarTypeController(carTypeService: carTypeService))
    try app.register(collection: ClientController(clientService: clientService))
    try app.register(collection: ContractController(contractService: contractService))
    try app.register(collection: DriverController(driverService: driverService))
    try app.register(collection: DriverTransckingController(trackingService: trackingService))
    try app.register(collection: DriverSessionController(driverSessionService: driverSessionService, clock: clock))
    try app.register(collection: TransitController(transitService: transitService))
    try app.register(collection: AddressController(addressRepository: addressRepository))
}
