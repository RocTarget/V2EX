import Foundation

protocol MemberService: HTMLParseService {
    /// 获取会员的主题列表
    ///
    /// - Parameters:
    ///   - username: 会员名字
    ///   - success: 成功
    ///   - failure: 失败
    func memberTopics(
        username: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?)
    
    /// 获取会员的回复列表
    ///
    /// - Parameters:
    ///   - username: 会员名字
    ///   - success: 成功
    ///   - failure: 失败
    func memberReplys(
        username: String,
        success: ((_ messages: [MessageModel]) -> Void)?,
        failure: Failure?)
    
    func memberHome(
        memberName: String,
        success: @escaping ((_ member: MemberModel, _ topics: [TopicModel], _ replys: [MessageModel]) -> Void),
        failure: Failure?)

    func memberProfile(
        memberName: String,
        success: @escaping ((_ member: MemberModel) -> Void),
        failure: Failure?)
}

extension MemberService {
    
    func memberTopics(
        username: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .memberTopics(username: username), success: { html in
            if let content = html.content, content.contains("主题列表被隐藏") {
                failure?("该用户隐藏了 主题列表")
                return
            }
            let topics = self.parseMemberTopics(html: html)
            success?(topics)
        }, failure: failure)
    }
    
    func memberReplys(
        username: String,
        success: ((_ messages: [MessageModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .memberReplys(username: username), success: { html in
            success?(self.parseMemberReplys(html: html))
        }, failure: failure)
    }
    
    func memberHome(
        memberName: String,
        success: @escaping ((_ member: MemberModel, _ topics: [TopicModel], _ replys: [MessageModel]) -> Void),
        failure: Failure?) {
        Network.htmlRequest(target: .memberHome(username: memberName), success: { html in
            guard let headerPath = html.xpath("//*[@id='Wrapper']/div/div[@class='box'][1]//tr").first,
                let avatar = headerPath.xpath("td/img").first?["src"],
                let username = headerPath.xpath("td[last()]/h1").first?.content,
                let joinTime =  headerPath.xpath("td[last()]/span[@class='gray']").first?.content else {
                failure?("数据解析失败")
                return
            }
            let follow = headerPath.xpath("td[last()]//input[1]").first?["onclick"]
            let block = headerPath.xpath("td[last()]//input[2]").first?["onclick"]
            var followHref: String?
            var blockHref: String?
            if let comps = follow?.components(separatedBy: "'"), comps.count > 4 {
                followHref = comps[3]
            }
            if let comps = block?.components(separatedBy: "'"), comps.count > 4 {
                blockHref = comps[3]
            }
            let messages = self.parseMemberReplys(html: html)

            let isFollow = followHref?.hasPrefix("/unfollow") ?? false
            let isBlock = blockHref?.hasPrefix("/unblock") ?? false

            let member = MemberModel(
                username: username,
                url: API.memberHome(username: username).path,
                avatar: avatar,
                joinTime: joinTime,
                followHref: followHref,
                blockHref: blockHref,
                isFollow: isFollow,
                isBlock: isBlock
            )
            
            let topics = self.parseMemberTopics(html: html)
            success(member, topics, messages)
        }, failure: failure)
    }

    func memberProfile(
        memberName: String,
        success: @escaping ((_ member: MemberModel) -> Void),
        failure: Failure?) {
        Network.htmlRequest(target: .memberHome(username: memberName), success: { html in
            guard let member = self.parseMemberProfile(html: html) else {
                failure?("数据解析失败")
                return
            }
            success(member)
        }, failure: failure)
    }
}
