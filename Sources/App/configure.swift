import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    if let url = Environment.get("DATABASE_URL"), let config = PostgresConfiguration.heroku(url: url) {
        app.databases.use(.postgres(
            configuration: config
        ), as: .psql)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    app.migrations.add(CreateTodo())

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
