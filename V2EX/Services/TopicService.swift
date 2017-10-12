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
}

extension TopicService {
    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Networking.shared.htmlRequest(target: .topics(href: nil), success: { html in
            
            let nodePath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='inner'][1]/a")
            let nodes = nodePath.flatMap({ ele -> NodeModel? in
                guard let href = ele["href"],
                    let name = ele.content else {
                        return nil
                }
                return NodeModel(name: name, href: href)
            })
            
            let itemPath = html.xpath("//body/div[@id='Wrapper']/div[@class='content']/div[@id='Main']/div[@class='box']/div[@class='cell item']")
            let topics = itemPath.flatMap({ ele -> TopicModel? in
                guard let userPage = ele.xpath(".//td/a").first?["href"],
                    let avatarSrc = ele.xpath(".//td/a/img").first?["src"],
                    let topicTitle = ele.xpath(".//td/span[@class='item_title']/a").first?.content,
                    let topicHref = ele.xpath(".//td/span[@class='item_title']/a").first?["href"],
                    let nodename = ele.xpath(".//td/span[@class='small fade']/a[@class='node']").first?.content,
                    let nodeHref = ele.xpath(".//td/span[@class='small fade']/a[@class='node']").first?["href"],
                    let username = ele.xpath(".//td/span[@class='small fade']/strong[1]").first?.content else {
                        return nil
                }
                let replyCount = Int(ele.xpath(".//td/a[@class='count_livid']").first?.content ?? "0") ?? 0
                var lastReplyTime: String?
                if let subs = ele.xpath(".//td/span[@class='small fade']").first?.text?.components(separatedBy: "•"), subs.count > 2 {
                    lastReplyTime = subs[2].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let user = UserModel(name: username, href: userPage, avatar: avatarSrc)
                let node = NodeModel(name: nodename, href: nodeHref)
                return TopicModel(user: user, node: node, title: topicTitle, content: "", href: topicHref, lastReplyTime: lastReplyTime, replyCount: replyCount)
            })
            success?(nodes, topics)
        }, failure: failure)
    }
    
    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        index(success: { (_, topics) in
            success?(topics)
        }, failure: failure)
    }
}
