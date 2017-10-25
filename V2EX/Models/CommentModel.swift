import Foundation
import Kanna

struct CommentModel {
    var id: String
    var member: MemberModel
    var content: String
    var publicTime: String
    var isThank: Bool = false
    var floor: String
    var thankCount: String?

    var contentUnwrapper: String {
        return HTML(html: content, encoding: .utf8)?.content ?? ""
    }
}
