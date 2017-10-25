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

extension CommentModel {
    
    /// 查找所有回复当中包含指定@用户的对话回复列表
    ///
    /// - Parameters:
    ///   - comments: 所有回复列表
    ///   - currentComment: 当前所选回复
    /// - Returns: 包含当前所选回复中所有@用户的对话回复列表
    static func atUsernameComments(comments: [CommentModel], currentComment:CommentModel) -> [CommentModel] {
        guard var atUsers = CommentModel.atUsernames(currentComment) else { return [] }
        atUsers.insert(currentComment.member.atUsernameWithoutSpace)
        
        let coms = comments.filter { comment -> Bool in
            guard let commentUsers = CommentModel.atUsernames(comment) else { return false }
            
            // 当前回复没有@用户.
            // 判断 1: 找出当前所选回复所有@的用户的回复
            //     2: 加入当前所选的回复
            if atUsers.count == 1 {
                return commentUsers.contains(currentComment.member.atUsernameWithoutSpace) || atUsers.contains(comment.member.atUsernameWithoutSpace)
            }
            let intersetions = commentUsers.intersection(atUsers)
            if commentUsers.count > 0 && intersetions.count <= 0 { return false }
            return atUsers.contains(comment.member.atUsernameWithoutSpace)
        }
        
        return coms
    }
    
    /// 解析回复当中所有 @ 的用户
    ///
    /// - Parameter comment: 回复模型
    /// - Returns: @用户的Set
    static func atUsernames(_ comment: CommentModel?) -> Set<String>?  {
        guard let `comment` = comment else { return nil }
        let text = comment.contentUnwrapper
        guard let result = TextParser.mentioned?.matches(in: text, options: .reportProgress, range: NSRange(location: 0, length: text.count)) else {
            return nil
        }
        
        var ats: [String] = []
        result.forEach { result in
            guard let range = result.range.range(for: text) else { return }
            let at = text[range]
            ats.append(String(at).trimmed)
        }
        return Set(ats)
    }
}
