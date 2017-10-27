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
        success: ((_ member: MemberModel, _ replys: [TopicModel], _ replys: [MessageModel]) -> Void),
        failure: Failure?)
}

extension MemberService {
    
    func memberTopics(
        username: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .memberTopics(username: username), success: { html in
            success?(self.parseMemberTopics(html: html))
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
        success: ((_ member: MemberModel, _ replys: [TopicModel], _ replys: [MessageModel]) -> Void),
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
            
//            let topicPath = html.xpath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[@class='cell item']")
//            let topics = self.parseTopic(html: html, type: .member)
            
            let titlePath = html.xpath("//*[@id='Wrapper']//div[@class='dock_area']")
            let contentPath = html.xpath("//*[@id='Wrapper']//div[@class='reply_content']")
            
            let messages = titlePath.enumerated().flatMap({ index, ele -> MessageModel? in
                guard let replyContent = contentPath[index].text,
                    let replyNode = ele.xpath(".//tr[1]/td[1]/span").first,
                    let replyDes = ele.content?.trimmed,
                    let topicNode = replyNode.xpath("./a").first,
                    let topicTitle = topicNode.content?.trimmed,
                    let topicHref = topicNode["href"],
                    let replyTime = ele.xpath(".//tr[1]/td/div/span").first?.content else {
                        return nil
                }
                
                let topic = TopicModel(member: nil, node: nil, title: topicTitle, href: topicHref)
                return MessageModel(
                    id: nil,
                    member: nil,
                    topic: topic,
                    time: replyTime,
                    content: replyContent,
                    replyTypeStr: replyDes,
                    once: nil)
            })
            
//            let  = html.xpath("//*[@id='Wrapper']/div/div[1]//tr/td[last()]/h1").first?.content
        }, failure: failure)
    }
}
