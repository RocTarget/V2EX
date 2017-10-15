import Foundation
import Kanna

protocol TopicService: HTMLParseService {
    
    
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
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
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

            let topics = self.parseTopicRootPath(html: html)

            success?(nodes, topics)
        }, failure: failure)
    }

    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: href), success: { html in
            let topics = self.parseTopicRootPath(html: html)
            success?(topics)
        }, failure: failure)
    }

    func topicDetail(
        topic: TopicModel,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: topic.href), success: { html in
            var `topic` = topic

            guard let publicTimeAndClickCountString = html.xpath("//*[@id='Main']//div[@class='header']/small/text()").first?.content else {
                // 需要登录
                if let error = html.xpath("//*[@id='Main']/div[2]/div[2]").first?.content {
                    failure?(error)
                    return
                }
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

            let commentPath = html.xpath("//*[@id='Main']/div[@class='box'][2]/div[contains(@id, 'r_')]")
            let comments = commentPath.flatMap({ ele -> CommentModel? in
                guard let userAvatar = ele.xpath("./table/tr/td/img").first?["src"],
                    let userPath = ele.xpath("./table/tr/td[3]/strong/a").first,
                    let userHref = userPath["href"],
                    let username = userPath.content,
                    let publicTime = ele.xpath("./table/tr/td[3]/span[@class='ago']").first?.content,
                    let content = ele.xpath("./table/tr/td[3]/div[@class='reply_content']").first?.content,
                    let floor = ele.xpath("./table/tr/td/div/span[@class='no']").first?.content else {
                        return nil
                }

                let id = ele["id"]?.replacingOccurrences(of: "r_", with: "") ?? "0"
                let user = UserModel(name: username, href: userHref, avatar: userAvatar)
                return CommentModel(id: id, user: user, content: content, publicTime: publicTime, floor: floor)
            })
            success?(topic, comments)
        }, failure: failure)
    }

    private func parseTopicRootPath(html: HTMLDocument) -> [TopicModel] {
        let rootPath = html.xpath("//*[@id='Main']/div[@class='box']/div[@class='cell item']")
        return self.parseTopic(rootPath: rootPath)
    }
    
}
