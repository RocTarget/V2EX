import Foundation
import Alamofire

enum API {

    case topics(href: String?)
    
    case captcha
    
    case captchaImageData(once: String)
    
    case signin
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
        case .captcha:
            return .get("/signin")
        case .captchaImageData(let once):
            return .get("/_captcha?once=\(once)")
        case .signin:
            return .get("/signin")
        }
    }

    /// The parameters to be encoded in the request.
    var parameters: [String : Any]? {
        let param: [String: Any] = [:]
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

