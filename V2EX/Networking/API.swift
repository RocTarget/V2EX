import Foundation
import Alamofire

enum CaptchaType: String {
    case signin = "/signin"
    case forgot = "/forgot"
}


enum API {

    case topics(href: String?)

    case topicDetail(topicID: String)

    case captcha(type: CaptchaType)

    case captchaImageData(once: String)
    
    case signin(dict: [String: String])

    case forgot(dict: [String: String])

    case signup(dict: [String: String])
    
    case myNodes
    
    case following
    
    case topicCollect

    case about

    case comment(topicID: String, dict: [String: String])

    case notifications

    case memberTopics(username: String)
    case memberReplys(username: String)

    case codeRepo
}

extension API: TargetType {

    /// The target's base `URL`.
    var baseURL: String {
        switch self {
        case .codeRepo:
            return "https://github.com/Joe0708/V2EX"
        default:
            return Constants.Config.baseURL
        }
    }

    var route: Route {
        switch self {
        case .topics(let href):
            return .get(href ?? "")
        case .topicDetail(let topicID):
            return .get("/t/\(topicID)")
        case .captcha(let type):
            return .get(type.rawValue)
        case .captchaImageData(let once):
            return .get("/_captcha?once=\(once)")
        case .signin:
            return .post("/signin")
        case .forgot:
            return .post("/forgot")
        case .signup:
            return .post("/signup")
        case .myNodes:
            return .get("/my/nodes")
        case .following:
            return .get("/my/following")
        case .topicCollect:
            return .get("/my/topics")
        case .about:
            return .get("/about")
        case .comment(let topicID, _):
            return .post("/t/\(topicID)")
        case .notifications:
            return .get("/notifications")
        case .memberTopics(let username):
            return .get("/member/\(username)/topics")
        case .memberReplys(let username):
            return .get("/member/\(username)/replies")
        default:
            return .get("")
        }
    }

    /// The parameters to be encoded in the request.
    var parameters: [String : Any]? {
        var param: [String: Any] = [:]
        switch self {
        case .signin(let dict),
             .forgot(let dict),
             .signup(let dict),
             .comment(_, let dict):
            param = dict
        default:
            return nil
        }
        return param
    }

    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return Alamofire.URLEncoding()
    }

    // Returns HTTP header values.
    var httpHeaderFields: [String: String]? {
        var headers: [String: String] = [:]
        headers["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
        switch self {
        case .signin, .forgot:
            headers["Referer"] = defaultURLString
        default:
            break
        }
        return headers
    }

    /// The type of HTTP task to be performed.
    var task: Task {
        return .request
    }
}

