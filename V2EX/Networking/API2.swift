//import Foundation
//import Alamofire
//
//
///// 查询的字段类型
/////
///// - topicId: 主题ID
///// - usernmae: 用户名
///// - nodeId: 节点ID
///// - nodemame: 节点名称
//enum QueryType {
//    case topicId(id: Int)
//    case usernmae(name: String)
//    case nodeId(id: Int)
//    case nodemame(name: String)
//
//    var queryString: String {
//        switch self {
//        case .topicId(let id):
//            return "id=\(id)"
//        case .usernmae(let name):
//            return "username=\(name)"
//        case .nodeId(let id):
//            return "node_id=\(id)"
//        case .nodemame(let name):
//            return "node_name=\(name)"
//        }
//    }
//}
//
//enum API {
//
//    // MARK: - 网站相关接口
//
//    // 获取网站信息 [GET /site/info.json]
//    //
//    // Response :
//    //    {
//    //        "title" : "V2EX",
//    //        "slogan" : "way to explore",
//    //        "description" : "创意工作者们的社区",
//    //        "domain" : "www.v2ex.com"
//    //    }
//    case siteInfo
//
//    // 获取网站状态 [GET /site/stats.json]
//    //
//    // Response :
//    //    {
//    //        "topic_max" : 126172,
//    //        "member_max" : 71033
//    //    }
//    case siteStats
//
//
//    // MARK: - 节点相关接口
//
//    // 获取所有节点列表 [GET /nodes/all.json]
//    //
//    // Response :
//    //    [
//    //        {
//    //            "id" : 1,
//    //            "name" : "babel",
//    //            "url" : "http://www.v2ex.com/go/babel",
//    //            "title" : "Project Babel",
//    //            "title_alternative" : "Project Babel",
//    //            "topics" : 1102,
//    //            "header" : "Project Babel \u002D 帮助你在云平台上搭建自己的社区",
//    //            "footer" : "V2EX 基于 Project Babel 驱动。Project Babel 是用 Python 语言写成的，运行于 Google App Engine 云计算平台上的社区软件。Project Babel 当前开发分支 2.5。最新版本可以从 \u003Ca href\u003D\u0022http://github.com/livid/v2ex\u0022 target\u003D\u0022_blank\u0022\u003EGitHub\u003C/a\u003E 获取。",
//    //            "created" : 1272206882
//    //        }
//    //    ]
//    case nodes
//
//    // 获得指定节点的名字，简介，URL 及头像图片的地址 [GET /nodes/show.json{?id,name}]
//    // id: 节点id
//    // name: 节点名字
//    // 节点 ID 和节点名两个参数二选一
//    //
//    // Request url = https://www.v2ex.com/api/nodes/show.json?name=python
//    // Response :
//    //    {
//    //        "id" : 90,
//    //        "name" : "python",
//    //        "url" : "http://www.v2ex.com/go/python",
//    //        "title" : "Python",
//    //        "title_alternative" : "Python",
//    //        "topics" : 7898,
//    //        "stars" : 5013,
//    //        "header" : "这里讨论各种 Python 语言编程话题，也包括 Django，Tornado 等框架的讨论。这里是一个能够帮助你解决实际问题的地方。",
//    //        "footer" : null,
//    //        "created" : 1278683336,
//    //        "avatar_mini" : "//v2ex.assets.uxengine.net/navatar/8613/985e/90_mini.png?m=1507539126",
//    //        "avatar_normal" : "//v2ex.assets.uxengine.net/navatar/8613/985e/90_normal.png?m=1507539126",
//    //        "avatar_large" : "//v2ex.assets.uxengine.net/navatar/8613/985e/90_large.png?m=1507539126"
//    //    }
//    case node(id: Int?, name: String?)
//
//
//    // MARK: - 主题相关接口
//
//    // 获取最新主题列表 [GET /topics/latest.json]
//    //
//    // Response :
//    //    [
//    //        {
//    //        "id" : 128177,
//    //        "title" : "vim\u002Dtranslator",
//    //        "url" : "http://www.v2ex.com/t/128177",
//    //        "content" : "一个轻巧的vim下的翻译和发音插件，依赖于 google\u002Dtranslator\u002Dcli，或者其他的命令行翻译，查询工具。发音取自google...\u000D\u000A\u000D\u000Ahttps://github.com/farseer90718/vim\u002Dtranslator\u000D\u000A\u000D\u000A功能比较简单。暂时只是实现了个人的需求...",
//    //        "content_rendered" : "一个轻巧的vim下的翻译和发音插件，依赖于 google\u002Dtranslator\u002Dcli，或者其他的命令行翻译，查询工具。发音取自google...\u003Cbr /\u003E\u003Cbr /\u003E\u003Ca target\u003D\u0022_blank\u0022 href\u003D\u0022https://github.com/farseer90718/vim\u002Dtranslator\u0022 rel\u003D\u0022nofollow\u0022\u003Ehttps://github.com/farseer90718/vim\u002Dtranslator\u003C/a\u003E\u003Cbr /\u003E\u003Cbr /\u003E功能比较简单。暂时只是实现了个人的需求...",
//    //        "replies" : 0,
//    //        "member" : {
//    //            "id" : 67060,
//    //            "username" : "farseer2014",
//    //            "tagline" : "",
//    //            "avatar_mini" : "//cdn.v2ex.com/avatar/6766/2b3d/67060_mini.png?m=1408121347",
//    //            "avatar_normal" : "//cdn.v2ex.com/avatar/6766/2b3d/67060_normal.png?m=1408121347",
//    //            "avatar_large" : "//cdn.v2ex.com/avatar/6766/2b3d/67060_large.png?m=1408121347"
//    //        },
//    //        "node" : {
//    //            "id" : 17,
//    //            "name" : "create",
//    //            "title" : "分享创造",
//    //            "title_alternative" : "Create",
//    //            "url" : "http://www.v2ex.com/go/create",
//    //            "topics" : 2621,
//    //            "avatar_mini" : "//cdn.v2ex.com/navatar/70ef/df2e/17_mini.png?m=1388448923",
//    //            "avatar_normal" : "//cdn.v2ex.com/navatar/70ef/df2e/17_normal.png?m=1388448923",
//    //            "avatar_large" : "//cdn.v2ex.com/navatar/70ef/df2e/17_large.png?m=1388448923"
//    //        },
//    //        "created" : 1408122614,
//    //        "last_modified" : 1408122614,
//    //        "last_touched" : 1408122434
//    //        }
//    //    ]
//    case topics
//
//    // 获取热门主题列表 [GET /topics/hot.json]
//    //
//    // Response :
//    //    [
//    //        {
//    //        "id" : 130248,
//    //        "title" : "今晚罗永浩和王自如优酷对质，大家预测谁会赢？",
//    //        "url" : "http://www.v2ex.com/t/130248",
//    //        "content" : "世界杯后遗症……想预测结果\u000D\u000A\u000D\u000A附图，不知道能不能看到\u000D\u000Ahttp://ww2.sinaimg.cn/bmiddle/61c921e5jw1ejrbvfjdvej20ri1fmahf.jpg",
//    //        "content_rendered" : "世界杯后遗症……想预测结果\u003Cbr /\u003E\u003Cbr /\u003E附图，不知道能不能看到\u003Cbr /\u003E\u003Ca target\u003D\u0022_blank\u0022 href\u003D\u0022http://ww2.sinaimg.cn/bmiddle/61c921e5jw1ejrbvfjdvej20ri1fmahf.jpg\u0022 target\u003D\u0022_blank\u0022\u003E\u003Cimg src\u003D\u0022http://ww2.sinaimg.cn/bmiddle/61c921e5jw1ejrbvfjdvej20ri1fmahf.jpg\u0022 class\u003D\u0022imgly\u0022 style\u003D\u0022max\u002Dwidth: 660px\u003B\u0022 border\u003D\u00220\u0022 /\u003E\u003C/a\u003E",
//    //        "replies" : 218,
//    //        "member" : {
//    //            "id" : 52028,
//    //            "username" : "sniper1211",
//    //            "tagline" : "",
//    //            "avatar_mini" : "//cdn.v2ex.com/avatar/1574/5f4c/52028_mini.png?m=1396973137",
//    //            "avatar_normal" : "//cdn.v2ex.com/avatar/1574/5f4c/52028_normal.png?m=1396973137",
//    //            "avatar_large" : "//cdn.v2ex.com/avatar/1574/5f4c/52028_large.png?m=1396973137"
//    //        },
//    //        "node" : {
//    //            "id" : 687,
//    //            "name" : "smartisanos",
//    //            "title" : "Smartisan OS",
//    //            "title_alternative" : "Smartisan OS",
//    //            "url" : "http://www.v2ex.com/go/smartisanos",
//    //            "topics" : 97,
//    //            "avatar_mini" : "//cdn.v2ex.com/navatar/7f5d/04d1/687_mini.png?m=1364402617",
//    //            "avatar_normal" : "//cdn.v2ex.com/navatar/7f5d/04d1/687_normal.png?m=1364402617",
//    //            "avatar_large" : "//cdn.v2ex.com/navatar/7f5d/04d1/687_large.png?m=1364402617"
//    //        },
//    //        "created" : 1409134584,
//    //        "last_modified" : 1409149779,
//    //        "last_touched" : 1409199522
//    //        }
//    //    ]
//    case hotTopics
//
//    // 获取指定主题信息 [GET /topics/show.json{?id,username,nodeid,nodename}]
//    // id: 根据主题ID查询主题详情
//    // username: 根据用户名取该用户所发表主题
//    // node_id:  根据节点id取该节点下所有主题
//    // node_name: 根据节点名取该节点下所有主题
//    // 参数 四选一
//    //
//    // Response :
//    //    [{
//    //        "id" : 1000,
//    //        "title" : "Google App Engine x MobileMe",
//    //        "url" : "http://www.v2ex.com/t/1000",
//    //        "content" : "从现在开始，新上传到 V2EX 的头像将存储在 MobileMe iDisk 中。这是 V2EX 到目前为之所用到的第三个云。\u000D\u000A\u000D\u000A得益于这个架构升级，现在头像上传之后，将立刻在全站的所有页面更新。",
//    //        "content_rendered" : "从现在开始，新上传到 V2EX 的头像将存储在 MobileMe iDisk 中。这是 V2EX 到目前为之所用到的第三个云。\u000D\u000A\u003Cbr /\u003E\u000D\u000A\u003Cbr /\u003E得益于这个架构升级，现在头像上传之后，将立刻在全站的所有页面更新。",
//    //        "replies" : 14,
//    //        "member" : {
//    //            "id" : 1,
//    //            "username" : "Livid",
//    //            "tagline" : "Beautifully Advance",
//    //            "avatar_mini" : "//cdn.v2ex.com/avatar/c4ca/4238/1_mini.png?m=1401650222",
//    //            "avatar_normal" : "//cdn.v2ex.com/avatar/c4ca/4238/1_normal.png?m=1401650222",
//    //            "avatar_large" : "//cdn.v2ex.com/avatar/c4ca/4238/1_large.png?m=1401650222"
//    //        },
//    //        "node" : {
//    //            "id" : 1,
//    //            "name" : "babel",
//    //            "title" : "Project Babel",
//    //            "url" : "http://www.v2ex.com/go/babel",
//    //            "topics" : 1102,
//    //            "avatar_mini" : "//cdn.v2ex.com/navatar/c4ca/4238/1_mini.png?m=1370299418",
//    //            "avatar_normal" : "//cdn.v2ex.com/navatar/c4ca/4238/1_normal.png?m=1370299418",
//    //            "avatar_large" : "//cdn.v2ex.com/navatar/c4ca/4238/1_large.png?m=1370299418"
//    //        },
//    //        "created" : 1280192329,
//    //        "last_modified" : 1335004238,
//    //        "last_touched" : 1280285385
//    //    }]
//    case topicShow(query: QueryType)
//
//
//    // MARK: - 主题回复相关接口
//
//    // 获取指定主题的所有回复列表 [GET /replies/show.json{?topicid,page,pagesize}]
//    // id: 主题ID（必选）
//    // page: 当前页数
//    // pageSize: 每页条数
//    //
//    // Response :
//    //    [
//    //        {
//    //        "id" : 1,
//    //        "thanks" : 5,
//    //        "content" : "很高兴看到 v2ex 又回来了，等了你半天发第一贴了，憋死我了。\u000D\u000A\u000D\u000Anice work~",
//    //        "content_rendered" : "很高兴看到 v2ex 又回来了，等了你半天发第一贴了，憋死我了。\u003Cbr /\u003E\u003Cbr /\u003Enice work~",
//    //        "member" : {
//    //            "id" : 4,
//    //            "username" : "Jay",
//    //            "tagline" : "",
//    //            "avatar_mini" : "//cdn.v2ex.com/avatar/a87f/f679/4_mini.png?m=1325831331",
//    //            "avatar_normal" : "//cdn.v2ex.com/avatar/a87f/f679/4_normal.png?m=1325831331",
//    //            "avatar_large" : "//cdn.v2ex.com/avatar/a87f/f679/4_large.png?m=1325831331"
//    //        },
//    //        "created" : 1272207477,
//    //        "last_modified" : 1335092176
//    //        }
//    //    ]
//    case replies(id: Int, page: Int?, pageSize: Int?)
//
//
//    // MARK: - 用户相关接口
//
//    // 获得指定用户的自我介绍，及其登记的社交网站信息 [GET /members/show.json{?username}]
//    // username: 用户名
//    // id: 用户在 V2EX 的数字 ID
//    // 二选一
//    //
//    // Request url =
//    // https://www.v2ex.com/api/members/show.json?id=16147
//    // or https://www.v2ex.com/api/members/show.json?username=djyde
//    // Response :
//    //    {
//    //        "status" : "found",
//    //        "id" : 16147,
//    //        "url" : "http://www.v2ex.com/member/djyde",
//    //        "username" : "djyde",
//    //        "website" : "https://lutaonan.com",
//    //        "twitter" : "randyloop",
//    //        "psn" : "RandyLooop",
//    //        "github" : "djyde",
//    //        "btc" : "",
//    //        "location" : "Guangdong,China",
//    //        "tagline" : "",
//    //        "bio" : "喜欢音乐和写作的程序员。",
//    //        "avatar_mini" : "//v2ex.assets.uxengine.net/avatar/ed4c/1b66/16147_mini.png?m=1409228135",
//    //        "avatar_normal" : "//v2ex.assets.uxengine.net/avatar/ed4c/1b66/16147_normal.png?m=1409228135",
//    //        "avatar_large" : "//v2ex.assets.uxengine.net/avatar/ed4c/1b66/16147_large.png?m=1409228135",
//    //        "created" : 1328075793
//    //    }
//    case member(id: Int?, username: String?)
//
//}
//
//extension API: TargetType {
//
//    /// The target's base `URL`.
//    var baseURL: String {
//        return Config.baseURL
//    }
//
//    var route: Route {
//        switch self {
//        case .siteInfo:
//            return .get("/site/info.json")
//        case .siteStats:
//            return .get("/site/stats.json")
//        case .nodes:
//            return .get("/nodes/all.json")
//        case .node:
//            return .get("/nodes/show.json")
//        case .topics:
//            return .get("/topics/latest.json")
//        case .hotTopics:
//            return .get("/topics/hot.json")
//        case .topicShow(let query):
//            return .get("/topics/show.json?id=\(query.queryString)")
//        case let .replies(id, page, pageSize):
//            var param = ""
//            if let `page` = page {
//                param = "&page=\(page)&page_size=\(pageSize ?? 20)"
//            }
//            return .get("/replies/show.json?topic_id=\(id)\(param)")
//        case .member(let username):
//            return .get("/members/show.json?username=\(username)")
//        }
//    }
//
//    /// The parameters to be encoded in the request.
//    var parameters: [String : Any]? {
//        var param: [String: Any] = [:]
//        switch self {
//        case let .node(id, name):
//            if let `id` = id {
//                param["id"] = id
//            } else if let `name` = name {
//                param["name"] = name
//            }
//        default:
//            return param
//        }
//        return param
//    }
//
//    /// The method used for parameter encoding.
//    var parameterEncoding: ParameterEncoding {
//        return Alamofire.URLEncoding()
//    }
//
//    /// Returns HTTP header values.
//    var httpHeaderFields: [String: String]? {
//        return ["Accept": "application/json"]
//    }
//
//    /// The type of HTTP task to be performed.
//    var task: Task {
//        return .request
//    }
//}

