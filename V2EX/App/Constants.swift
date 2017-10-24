import Foundation
import UIKit

struct Closure {
    typealias Completion = () -> Void
    typealias Failure = (NSError?) -> Void
}

struct Constants {

    struct Config {
        // App
        static var baseURL = "https://www.v2ex.com"

        static var URIScheme = "https:"
        
        static var receiverEmail = "joesir7@foxmail.com"
    }

    struct Keys {
        // User 登录时的用户名
        static let loginAccount = "loginAccount"
        
        // User 持久化
        static let username = "usernameKey"
        static let avatarSrc = "avatarSrcKey"

        // 创建主题的草稿
        static let createTopicTitleDraft = "createTopicTitleDraft"
        static let createTopicBodyDraft = "createTopicBodyDraft"
    }
}

// MARK: - 通知
extension Notification.Name {
    
    /// 自定义的通知
    struct V2 {

        /// 解析到 未读提醒 时的通知
        static let UnreadNoticeName = Notification.Name("UnreadNoticeName")

        /// 登录成功通知
        static let LoginSuccessName = Notification.Name("LoginSuccessName")
    }
}


