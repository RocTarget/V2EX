import Foundation

struct TopicModel {
    var user: UserModel
    var node: NodeModel
    
    var title: String
    var content: String
    var href: String
    var lastReplyTime: String?
    var replyCount: Int
}
