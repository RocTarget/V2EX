import Foundation

struct MessageModel {

    var id: String?
    var member: MemberModel?
    var topic: TopicModel
    var time: String
    var content: String
    var replyTypeStr: String
    var once: String?
}
