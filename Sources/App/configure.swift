import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    if let url = Environment.get("DATABASE_URL"), let config = PostgresConfiguration.heroku(url: url) {
        app.databases.use(.postgres(
            configuration: config
        ), as: .psql)
    } else {
        app.databases.use(.sqlite(.file("/Users/rzeszot/Work/edu/cabs-swift/db.sqlite")), as: .sqlite)
    }

    app.logger.logLevel = .trace

    app.migrations.add(CreateCarType())
    app.migrations.add(CreateClient())
    app.migrations.add(CreateContract())
    app.migrations.add(CreateContractAttachment())
    app.migrations.add(CreateAddress())
    app.migrations.add(CreateDriver())
    app.migrations.add(CreateDriverFee())
    app.migrations.add(CreateDriverAttribute())
    app.migrations.add(CreateDriverPosition())
    app.migrations.add(CreateDriverSession())
    app.migrations.add(CreateInvoice())
    app.migrations.add(CreateAwardsAccount())
    app.migrations.add(CreateTransit())

    try routes(app)
}

private extension PostgresConfiguration {
    static func heroku(url: String) -> PostgresConfiguration? {
        var config = PostgresConfiguration(url: url)
        config?.tlsConfiguration = .makeClientConfiguration()
        config?.tlsConfiguration?.certificateVerification = .none
        return config
    }
}
