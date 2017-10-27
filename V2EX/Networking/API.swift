import Foundation
import Alamofire

enum CaptchaType: String {
    case signin = "/signin"
    case forgot = "/forgot"
}

// V2EX js
// https://www.v2ex.com/static/js/v2ex.js?v=2658dbd9f54ebdeb51d27a0611b2ba96

enum API {
    
    case topics(href: String?)

    case recentTopics(page: Int)

    case topicDetail(topicID: String, page: Int)
    
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
    
    case notifications(page: Int)
    case deleteNotification(notifacationID: String, once: String)
    
    case memberTopics(username: String)
    case memberReplys(username: String)
    
    // 源码地址
    case codeRepo
    
    // 搜索主题
    case search(query: String, offset: Int, size: Int, sortType: String)
    
    // 收藏主题
    case favoriteTopic(topicID: String, token: String)
    // 取消收藏主题
    case unfavoriteTopic(topicID: String, token: String)
    // 感谢主题
    case thankTopic(topicID: String, token: String)
    // 忽略主题
    case ignoreTopic(topicID: String, once: String)
    // 感谢回复
    case thankReply(replyID: String, token: String)
    // 忽略回复
    case ignoreReply(replyID: String, once: String)
    // 预览 Markdown
    case previewTopic(md: String, once: String)

    // 上传图片
    case uploadPicture(localURL: String)
}

extension API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: String {
        switch self {
        case .codeRepo:
            return "https://github.com/Joe0708/V2EX"
        case .search:
            return "https://www.sov2ex.com/api/search"
        case .uploadPicture:
            return "https://sm.ms/api"
        default:
            return Constants.Config.baseURL
        }
    }
    
    var route: Route {
        switch self {
        case .topics(let href):
            return .get(href ?? "")
        case .recentTopics(let page):
            return .get("/recent?p=\(page)")
        case .topicDetail(let topicID, let page):
            return .get("/t/\(topicID)?p=\(page)")
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
        case .notifications(let page):
            return .get("/notifications?p=\(page)")
        case let .deleteNotification(notifacationID, once):
            return .post("/delete/notification/\(notifacationID)?once=\(once)")
        case .memberTopics(let username):
            return .get("/member/\(username)/topics")
        case .memberReplys(let username):
            return .get("/member/\(username)/replies")
        case .createTopic(let nodename, _):
            return .post("/new/\(nodename)")
        case let .favoriteTopic(topicID, token):
            return .get("/favorite/topic/\(topicID)?t=\(token)")
        case let .unfavoriteTopic(topicID, token):
            return .get("/unfavorite/topic/\(topicID)?t=\(token)")
        case let .thankTopic(topicID, token):
            return .post("/thank/topic/\(topicID)?t=\(token)")
        case let .ignoreTopic(topicID, once):
            return .get("/ignore/topic/\(topicID)?once=\(once)")
        case let .thankReply(replyID, token):
            return .post("/thank/reply/\(replyID)?t=\(token)")
        case let .ignoreReply(replyID, once):
            return .post("/ignore/reply/\(replyID)?once=\(once)")
        case let .previewTopic(md, once):
            return .post("/preview/markdown?md=\(md)&once=\(once)&syntax=1")
        case .uploadPicture:
            return .post("/upload")
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
        switch self {
        case .uploadPicture(let localURL):
            return .upload(.file(URL(fileURLWithPath: localURL)))
        default:
            return .request
        }
    }
}

