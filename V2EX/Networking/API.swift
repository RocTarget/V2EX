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

    case loginReward(once: String)
    
    // 我的节点
    case myNodes
    
    // 全部节点
    case nodes
    
    case following
    
    case topicCollect
    
    case about
    
    case comment(topicID: String, dict: [String: String])
    case createTopic(nodename: String, dict: [String: String])
    
    case notifications
    
    case memberTopics(username: String)
    case memberReplys(username: String)
    
    case codeRepo
    
    case search(query: String, offset: Int, size: Int, sortType: String)
    
    // 忽略主题
    case ignoreTopic(topicID: String, once: String)
    // 收藏主题
    case favoriteTopic(topicID: String, token: String)
    // 取消收藏主题
    case unfavoriteTopic(topicID: String, token: String)
    // 感谢主题
    case thankTopic(topicID: String, token: String)
}

extension API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: String {
        switch self {
        case .codeRepo:
            return "https://github.com/Joe0708/V2EX"
        case .search:
            return "https://www.sov2ex.com/api/search"
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
        case .loginReward(let once):
            return .post("/mission/daily/redeem?once=\(once)")
        case .nodes:
            return .get("/api/nodes/all.json")
        // return .get("/planes")
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
        case .createTopic(let nodename, _):
            return .post("/new/\(nodename)")
        case let .ignoreTopic(topicID, once):
            return .get("/ignore/topic\(topicID)?once=\(once)")
        case let .favoriteTopic(topicID, token):
            return .get("/favorite/topic/\(topicID)?t=\(token)")
        case let .unfavoriteTopic(topicID, token):
            return .get("/unfavorite/topic/\(topicID)?t=\(token)")
        case let .thankTopic(topicID, token):
            return .get("/thank/topic/\(topicID)?t=\(token)")
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
             .comment(_, let dict),
             .createTopic(_, let dict):
            param = dict
        case let .search(query, offset, size, sortType):
            param["q"] = query
            param["from"] = offset
            param["size"] = size
            param["sort"] = sortType
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
        //        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.91 Safari/537.36"
        switch self {
        case .signin, .forgot, .createTopic:
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

