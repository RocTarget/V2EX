import Foundation

struct CommentModel {
    var id: String
    var member: MemberModel
    var content: String
    var publicTime: String
    var isThank: Bool = false
    var floor: String
}
