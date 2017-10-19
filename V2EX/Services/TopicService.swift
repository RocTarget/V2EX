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

    func topicDetail(
        topicID: String,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?)

    func comment(
        once: String,
        topicID: String,
        content: String,
        success: Action?,
        failure: Failure?)

}

extension TopicService {

    func index(
        success: ((_ nodes: [NodeModel], _ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Networking.shared.htmlRequest(target: .topics(href: nil), success: { html in

            //            let nodePath = html.xpath("//*[@id='Wrapper']/div/div[3]/div[2]/a")
            
            // 有通知 代表登录成功
            var isLogin = false
            if let innerHTML = html.innerHTML {
                isLogin = innerHTML.contains("notifications")
                if  isLogin {
                    // 领取今日登录奖励
                    if let dailyHref = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='inner']/a").first?["href"],
                        dailyHref == "/mission/daily" {
                    }
                    
                    //
                    if let avatarNode = html.xpath("//*[@id='Top']/div/div/table/tr/td[3]/a[1]/img[1]").first,
                        let avatarPath = avatarNode["src"]?.replacingOccurrences(of: "s=24", with: "s=55"), // 修改图片尺寸
                        let href = avatarNode.parent?["href"] {
                        let username = href.lastPathComponent

                        UserModel(username: username, url: href, avatar: avatarPath).save()
                    }
                }
            }
            
            //  已登录 div[2] / 没登录 div[1]
            let nodePath = html.xpath("//*[@id='Wrapper']/div[@class='content']/div/div[\(isLogin ? 2 : 1)]/a")

            let nodes = nodePath.flatMap({ ele -> NodeModel? in
                guard let href = ele["href"],
                    let name = ele.content else {
                        return nil
                }
                let isCurrent = ele.className == "tab_current"

                return NodeModel(name: name, href: href, isCurrent: isCurrent)
            })//.filter { $0.href != "/?tab=nodes" } // 过滤导航上的 ‘节点’ 节点

            let topics = self.parseTopicRootPath(html: html)

            guard topics.count > 0 else {
                failure?("获取节点信息失败")
                return
            }
            success?(nodes, topics)
        }, failure: failure)
    }

    func topics(
        href: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: href), success: { html in
            let topics = self.parseTopicRootPath(html: html)

            guard topics.count > 0 else {
                failure?("获取节点信息失败")
                return
            }

            success?(topics)
        }, failure: failure)
    }

    func topicDetail(
        topic: TopicModel,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topics(href: topic.href), success: { html in
            var `topic` = topic

            guard let publicTimeAndClickCountString = html.xpath("//*[@id='Wrapper']//div[@class='header']/small/text()[2]").first?.text else {
                // 需要登录
                if let error = html.xpath("//*[@id='Wrapper']/div[2]/div[2]").first?.content {
                    failure?(error)
                    return
                }
                failure?("数据解析失败")
                return
            }
            topic.publicTime = publicTimeAndClickCountString
            topic.once = self.parseOnce(html: html)

//            let publicTimeAndClickCountList = publicTimeAndClickCountString.trimmed.components(separatedBy: "·").map { $0.trimmed }.filter { $0.isNotEmpty }
//            if publicTimeAndClickCountList.count >= 2 {
//            }

            let contentHTML = html.xpath("//*[@id='Wrapper']//div[@class='topic_content']").first?.toHTML ?? ""
            let subtleHTML = html.xpath("//*[@id='Wrapper']//div[@class='subtle']").flatMap { $0.toHTML }.joined(separator: "")
            let content = contentHTML + subtleHTML

            topic.content = content

            let commentPath = html.xpath("//*[@id='Wrapper']//div[@class='box'][2]/div[contains(@id, 'r_')]")
            let comments = commentPath.flatMap({ ele -> CommentModel? in
                guard let userAvatar = ele.xpath("./table/tr/td/img").first?["src"],
                    let userPath = ele.xpath("./table/tr/td[3]/strong/a").first,
                    let userHref = userPath["href"],
                    let username = userPath.content,
                    let publicTime = ele.xpath("./table/tr/td[3]/span").first?.content,
                    let content = ele.xpath("./table/tr/td[3]/div[@class='reply_content']").first?.content,
                    let floor = ele.xpath("./table/tr/td/div/span[@class='no']").first?.content else {
                        return nil
                }

                let id = ele["id"]?.replacingOccurrences(of: "r_", with: "") ?? "0"
                let user = UserModel(username: username, url: userHref, avatar: userAvatar)
                return CommentModel(id: id, user: user, content: content, publicTime: publicTime, floor: floor)
            })
            success?(topic, comments)
        }, failure: failure)
    }

    func topicDetail(
        topicID: String,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?) {

        Network.htmlRequest(target: .topicDetail(topicID: topicID), success: { html in

            guard let _ = html.xpath("//*[@id='Wrapper']//div[@class='header']/small/text()[2]").first?.text else {
                // 需要登录
                if let error = html.xpath("//*[@id='Wrapper']/div[2]/div[2]").first?.content {
                    failure?(error)
                    return
                }
                failure?("数据解析失败")
                return
            }

            let contentHTML = html.xpath("//*[@id='Wrapper']//div[@class='topic_content']").first?.toHTML ?? ""
            let subtleHTML = html.xpath("//*[@id='Wrapper']//div[@class='subtle']").flatMap { $0.toHTML }.joined(separator: "")
            let content = contentHTML + subtleHTML

            let commentPath = html.xpath("//*[@id='Wrapper']//div[@class='box'][2]/div[contains(@id, 'r_')]")
            let comments = commentPath.flatMap({ ele -> CommentModel? in
                guard let userAvatar = ele.xpath("./table/tr/td/img").first?["src"],
                    let userPath = ele.xpath("./table/tr/td[3]/strong/a").first,
                    let userHref = userPath["href"],
                    let username = userPath.content,
                    let publicTime = ele.xpath("./table/tr/td[3]/span").first?.content,
                    var content = ele.xpath("./table/tr/td[3]/div[@class='reply_content']").first?.toHTML,
                    let floor = ele.xpath("./table/tr/td/div/span[@class='no']").first?.content else {
                        return nil
                }
                content = self.replacingIframe(text: content)

                let id = ele["id"]?.replacingOccurrences(of: "r_", with: "") ?? "0"
                let user = UserModel(username: username, url: userHref, avatar: userAvatar)
                return CommentModel(id: id, user: user, content: content, publicTime: publicTime, floor: floor)
            })
            guard let userPath = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/div/a").first,
            let userAvatar = userPath.xpath("./img").first?["src"],
                let userhref = userPath["href"],
                let nodeEle = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/a[2]").first,
                let nodename = nodeEle.content,
                let nodeHref = nodeEle["href"],
                let title = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[@class='header']/h1").first?.content else {
                    failure?("数据解析失败")
                    return
            }

            let user = MemberModel(username: userhref.lastPathComponent, url: userhref, avatar: userAvatar)
            let node = NodeModel(name: nodename, href: nodeHref)
            var topic = TopicModel(user: user, node: node, title: title, href: "", lastReplyTime: "", replyCount: 0)
            topic.once = self.parseOnce(html: html)
            topic.content = content
            topic.publicTime = html.xpath("//*[@id='Wrapper']/div/div[1]/div[1]/small/text()[2]").first?.content ?? ""
            success?(topic, comments)
        }, failure: failure)
    }

    func comment(
        once: String,
        topicID: String,
        content: String,
        success: Action?,
        failure: Failure?) {

        let param = [
            "content": content,
            "once": once
        ]
        Network.htmlRequest(target: .comment(topicID: topicID, dict: param), success: { html in
            guard let problem =  html.xpath("//*[@id='Wrapper']/div//div[@class='problem']/ul").first?.content else {
                success?()
                return
            }

            failure?(problem)
        }, failure: failure)
    }

    private func parseTopicRootPath(html: HTMLDocument) -> [TopicModel] {
        let rootPath = html.xpath("//*[@id='Wrapper']/div/div/div[@class='cell item']")
        return self.parseTopic(rootPath: rootPath)
    }
}
