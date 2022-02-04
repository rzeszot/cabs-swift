import Fluent
import Vapor

func routes(_ app: Application) throws {
    let appProperties = AppProperties()

    let carTypeRepository = CarTypeRepository(database: app.db)
    let carTypeService = CarTypeService(carTypeRepository: carTypeRepository, appProperties: appProperties)

    let clientRepository = ClientRepository(database: app.db)
    let clientService = ClientService(clientRepository: clientRepository)

    let contractRepository = ContractRepository(database: app.db)
    let attachmentRepository = ContractAttachmentRepository(database: app.db)
    let contractService = ContractService(contractRepository: contractRepository, attachmentRepository: attachmentRepository)

    let driverRepository = DriverRepository(database: app.db)
    let driverService = DriverService(driverRepository: driverRepository)

    app.get { req -> String in
        return "cabs-swift"
    }

    try app.register(collection: CarTypeController(carTypeService: carTypeService))
    try app.register(collection: ClientController(clientService: clientService))
    try app.register(collection: ContractController(contractService: contractService))
    try app.register(collection: DriverController(driverService: driverService))
}
