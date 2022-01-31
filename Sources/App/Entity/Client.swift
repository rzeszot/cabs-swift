import Fluent
import Vapor

class Client: Model {
    enum Kind: String, Codable {
        case normal
        case vip
    }

    enum ClientKind: String, Codable {
        case individual
        case company
    }

    enum PaymentKind: String, Codable {
        case pre_paid
        case post_paid
        case monthly_invoice
    }

    // MARK: -

    static let schema = "clients"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "type")
    var kind: Kind

    @Field(key: "client_type")
    var clientKind: ClientKind

    @Field(key: "default_payment_type")
    var defaultPaymentKind: PaymentKind

    required init() {

    }
}

//public List<Claim> getClaims() {
//    return claims;
//}
//
//public void setClaims(List<Claim> claims) {
//    this.claims = claims;
//}
//
//@OneToMany(mappedBy = "owner")
//private List<Claim> claims = new ArrayList<>();
