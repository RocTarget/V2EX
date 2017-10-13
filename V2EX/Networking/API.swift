import Foundation
import Alamofire

enum API {

    case topics(href: String?)
}


extension API: TargetType {

    /// The target's base `URL`.
    var baseURL: String {
        return Config.baseURL
    }

    var route: Route {
        switch self {
        case .topics(let href):
            return .get(href ?? "")
        }
    }

    /// The parameters to be encoded in the request.
    var parameters: [String : Any]? {
        var param: [String: Any] = [:]
        return param
    }

    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return Alamofire.URLEncoding()
    }

    /// Returns HTTP header values.
    var httpHeaderFields: [String: String]? {
        return ["Accept": "application/json"]
    }

    /// The type of HTTP task to be performed.
    var task: Task {
        return .request
    }
}

