import Foundation

public struct TopicModel {
    var user: MemberModel
    var node: NodeModel?

    var title: String
    var content: String = ""
    var href: String
    var lastReplyTime: String?
    var replyCount: Int

    var publicTime: String = ""

    var once: String?

    /// 主题 ID
    var topicId: String? {
        let isTopic = href.hasPrefix("/t/")
        guard isTopic,
            let topicId = href.replacingOccurrences(of: "/t/", with: "").components(separatedBy: "#").first else {
            return nil
        }
       return topicId
    }

    init(user: MemberModel, node: NodeModel?, title: String, href: String, lastReplyTime: String?, replyCount: Int) {
        self.user = user
        self.node = node
        self.title = title
        self.href = href
        self.lastReplyTime = lastReplyTime
        self.replyCount = replyCount
    }
}
