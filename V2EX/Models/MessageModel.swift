import Foundation

struct MessageModel {

    var user: UserModel?
    var topic: TopicModel
    var time: String
    var content: String
    var replyTypeStr: String
}
