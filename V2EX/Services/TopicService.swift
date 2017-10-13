import Foundation
import Kanna

protocol TopicService {
    
    
    /// 获取 首页 数据
    ///
    /// - Parameters:
    ///   - success: 成功返回 nodes, topics, navigations
    ///   - failure: 失败
    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel]) -> Void)?,
        failure: Failure?)
    
    /// 获取 首页 主题数据
    ///
    /// - Parameters:
    ///   - href: href
    ///   - success: 成功返回 topics
    ///   - failure: 失败
    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?)

    func topicDetail(
        topic: TopicModel,
        success: ((_ topic: TopicModel) -> Void)?,
        failure: Failure?)
}

extension TopicService {

    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Networking.shared.htmlRequest(target: .topics(href: nil), success: { html in

            let nodePath = html.xpath("//*[@id='Tabs']/a")
            let nodes = nodePath.flatMap({ ele -> NodeModel? in
                guard let href = ele["href"],
                    let name = ele.content else {
                        return nil
                }
                let isCurrent = ele.className == "tab_current"
                return NodeModel(name: name, href: href, isCurrent: isCurrent)
            })

            let topics = self.parseTopic(html: html)

            self.parseNodeNav(html: html)

            success?(nodes, topics)
        }, failure: failure)
    }
    
    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: href), success: { html in
            let topics = self.parseTopic(html: html)
            success?(topics)
        }, failure: failure)
    }

    func topicDetail(
        topic: TopicModel,
        success: ((_ topic: TopicModel) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: topic.href), success: { html in
            var `topic` = topic

            guard let publicTimeAndClickCountString = html.xpath("//*[@id='Main']//div[@class='header']/small/text()").first?.content else {
                failure?("数据解析失败")
                return
            }
            let publicTimeAndClickCountList = publicTimeAndClickCountString.trimmed.components(separatedBy: "·").map { $0.trimmed }.filter { $0.isNotEmpty }

            if publicTimeAndClickCountList.count >= 2 {
                topic.publicTime = publicTimeAndClickCountList[0]
                topic.clickCount = publicTimeAndClickCountList[1]
            }

            let contentHTML = html.xpath("//*[@id='Main']//div[@class='topic_content']").first?.toHTML ?? ""
            let subtleHTML = html.xpath("//*[@id='Main']//div[@class='subtle']").flatMap { $0.toHTML }.joined(separator: "")
            let content = contentHTML + subtleHTML

            topic.content = content

            success?(topic)
        }, failure: failure)
    }

    /// 解析主题列表
    ///
    /// - Parameter html: HTMLDoc
    /// - Returns: topic model
    private func parseTopic(html: HTMLDocument) -> [TopicModel] {
        let itemPath = html.xpath("//*[@id='Main']/div[@class='box']/div[@class='cell item']")
        let topics = itemPath.flatMap({ ele -> TopicModel? in
            guard let userPage = ele.xpath(".//td/a").first?["href"],
                let avatarSrc = ele.xpath(".//td/a/img").first?["src"],
                let topicPath = ele.xpath(".//td/span[@class='item_title']/a").first,
                let topicTitle = topicPath.content,
                let topicHref = topicPath["href"],
                let nodePath = ele.xpath(".//td/span[@class='small fade']/a[@class='node']").first,
                let nodename = nodePath.content,
                let nodeHref = nodePath["href"],
                let username = ele.xpath(".//td/span[@class='small fade']/strong[1]").first?.content else {
                    return nil
            }
            let replyCount = Int(ele.xpath(".//td/a[@class='count_livid']").first?.content ?? "0") ?? 0
            var lastReplyTime: String?
            if let subs = ele.xpath(".//td/span[@class='small fade']").first?.text?.components(separatedBy: "•"), subs.count > 2 {
                lastReplyTime = subs[2].trimmed
            }
            let user = UserModel(name: username, href: userPage, avatar: avatarSrc)
            let node = NodeModel(name: nodename, href: nodeHref)
            return TopicModel(user: user, node: node, title: topicTitle, href: topicHref, lastReplyTime: lastReplyTime, replyCount: replyCount)
        })

        return topics
    }

    private func parseNodeNav(html: HTMLDocument) {

    }

}
