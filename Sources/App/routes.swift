import Fluent
import Vapor

func routes(_ app: Application) throws {
    let appProperties = AppProperties()

    let carTypeRepository = CarTypeRepository(database: app.db)
    let carTypeService = CarTypeService(carTypeRepository: carTypeRepository, appProperties: appProperties)

    let clientRepository = ClientRepository(database: app.db)
    let clientService = ClientService(clientRepository: clientRepository)

    app.get { req -> String in
        return "cabs-swift"
    }

    try app.register(collection: CarTypeController(carTypeService: carTypeService))
    try app.register(collection: ClientController(clientService: clientService))
}
