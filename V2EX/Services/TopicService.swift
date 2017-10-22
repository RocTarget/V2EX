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
    
    /// 获取 主题 详情数据
    ///
    /// - Parameters:
    ///   - topic: topic
    ///   - success: 成功
    ///   - failure: 失败
    func topicDetail(
        topic: TopicModel,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?)
    
    /// 获取 主题 详情数据
    ///
    /// - Parameters:
    ///   - topic: topic
    ///   - success: 成功
    ///   - failure: 失败
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
    
    func createTopic(
        nodename: String,
        title: String,
        body: String?,
        success: Action?,
        failure: @escaping Failure)
    
    func memberTopics(
        username: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?)
    
    func memberReply(
        username: String,
        success: ((_ messages: [MessageModel]) -> ())?,
        failure: Failure?)
    
    func search(
        query: String,
        offset: Int,
        size: Int,
        sortType: SearchSortType,
        success: ((_ results: [SearchResultModel]) -> ())?,
        failure: Failure?)
    
    // 忽略主题
    func ignoreTopic(topicID: String,
                     token: String,
                     success: Action?,
                     failure: Failure?)
    // 收藏主题
    func favoriteTopic(topicID: String,
                       token: String,
                       success: Action?,
                       failure: Failure?)
    // 取消收藏主题
    func unfavoriteTopic(topicID: String,
                         token: String,
                         success: Action?,
                         failure: Failure?)
    // 感谢主题
    func thankTopic(topicID: String,
                    token: String,
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
                        
                        AccountModel(username: username, url: href, avatar: avatarPath).save()
                    }
                }
            }
            
            //  已登录 div[2] / 没登录 div[1]
            let nodePath = html.xpath("//*[@id='Wrapper']/div[@class='content']/div/div[\(isLogin ? 2 : 1)]/a")
            
            var nodes = nodePath.flatMap({ ele -> NodeModel? in
                guard let href = ele["href"],
                    let name = ele.content else {
                        return nil
                }
                let isCurrent = ele.className == "tab_current"
                
                return NodeModel(name: name, href: href, isCurrent: isCurrent)
            })//.filter { $0.href != "/?tab=nodes" } // 过滤导航上的 ‘节点’ 节点
            
            let recent = NodeModel(name: "最近", href: "/recent")
            nodes.insert(recent, at: 0)
            
            let topics = self.parseTopic(html: html, type: .index)
            
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
            let topics = self.parseTopic(html: html, type: .index)
            
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
                let member = MemberModel(username: username, url: userHref, avatar: userAvatar)
                return CommentModel(id: id, member: member, content: content, publicTime: publicTime, floor: floor)
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
                let member = MemberModel(username: username, url: userHref, avatar: userAvatar)
                return CommentModel(id: id, member: member, content: content, publicTime: publicTime, floor: floor)
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
            
            let member = MemberModel(username: userhref.lastPathComponent, url: userhref, avatar: userAvatar)
            let node = NodeModel(name: nodename, href: nodeHref)
            var topic = TopicModel(member: member, node: node, title: title, href: "")
            
            // 获取 token
            if let csrfTokenPath = html.xpath("//*[@id='Wrapper']/div[@class='content']/div/div[@class='inner']//a[1]").first?["href"] {
                let csrfToken = URLComponents(string: csrfTokenPath)?["t"]
                let isFavorite = csrfTokenPath.hasPrefix("/unfavorite")
                topic.token = csrfToken
                topic.isFavorite = isFavorite
            }
            
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
        
        let params = [
            "content": content,
            "once": once
        ]
        
        Network.htmlRequest(target: .comment(topicID: topicID, dict: params), success: { html in
            guard let problem =  html.xpath("//*[@id='Wrapper']/div//div[@class='problem']/ul").first?.content else {
                success?()
                return
            }
            
            failure?(problem)
        }, failure: failure)
    }
    
    func createTopic(
        nodename: String,
        title: String,
        body: String?,
        success: Action?,
        failure: @escaping Failure) {
        
        Network.htmlRequest(target: .createTopic(nodename: nodename, dict: [:]), success: { html in
            guard let once = self.parseOnce(html: html) else {
                failure("无法授权失败")
                return
            }
            let params = [
                "title": title,
                "content": body ?? "",
                "once": once,
                "syntax": "1" //文本标记语法, 0: 默认 1: Markdown
            ]
            Network.htmlRequest(target: .createTopic(nodename: nodename, dict: params), success: { html in
                guard let problem =  html.xpath("//*[@id='Wrapper']/div//div[@class='problem']/ul").first?.content else {
                    success?()
                    return
                }
                failure(problem)
            }, failure: failure)
        }, failure: failure)
        
    }
    func memberTopics(
        username: String,
        success: ((_ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        
        Network.htmlRequest(target: .memberTopics(username: username), success: { html in
            let rootPath = html.xpath("//*[@id='Wrapper']/div/div/div[@class='cell item']")
            let topics = rootPath.flatMap({ ele -> TopicModel? in
                guard let userNode = ele.xpath(".//td//span/strong/a").first,
                    let userPage = userNode["href"],
                    let username = userNode.content,
                    let topicPath = ele.xpath(".//td/span[@class='item_title']/a").first,
                    let topicTitle = topicPath.content,
                    //                    let avatarSrc = ele.xpath(".//td/a/img").first?["src"],
                    let avatarSrc = UserDefaults.get(forKey: Constants.Keys.avatarSrc) as? String,
                    let topicHref = topicPath["href"] else {
                        return nil
                }
                
                
                let replyCount = ele.xpath(".//td[2]/a").first?.text ?? "0"
                
                let homeXPath = ele.xpath(".//td/span[3]/text()").first
                let nodeDetailXPath = ele.xpath(".//td/span[2]/text()").first
                let textNode = homeXPath ?? nodeDetailXPath
                let timeString = textNode?.content ?? ""
                let replyUsername = textNode?.parent?.xpath("./strong").first?.content ?? ""
                
                var lastReplyAndTime: String = ""
                if homeXPath != nil { // 首页的布局
                    lastReplyAndTime = timeString + replyUsername
                } else if nodeDetailXPath != nil {
                    lastReplyAndTime = replyUsername + timeString
                }
                
                let member = MemberModel(username: username, url: userPage, avatar: avatarSrc)
                
                var node: NodeModel?
                
                if let nodePath = ele.xpath(".//td/span[@class='small fade']/a[@class='node']").first,
                    let nodename = nodePath.content,
                    let nodeHref = nodePath["href"] {
                    node = NodeModel(name: nodename, href: nodeHref)
                }
                
                return TopicModel(member: member, node: node, title: topicTitle, href: topicHref, lastReplyTime: lastReplyAndTime, replyCount: replyCount)
            })
            
            guard topics.count > 0 else {
                failure?("获取节点信息失败")
                return
            }
            
            success?(topics)
        }, failure: failure)
    }
    
    func memberReply(
        username: String,
        success: ((_ messages: [MessageModel]) -> ())?,
        failure: Failure?) {
        Network.htmlRequest(target: .memberReplys(username: username), success: { html in
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
                return MessageModel(member: nil, topic: topic, time: replyTime, content: replyContent, replyTypeStr: replyDes)
            })
            success?(messages)
        }, failure: failure)
    }
    
    func search(
        query: String,
        offset: Int,
        size: Int,
        sortType: SearchSortType,
        success: ((_ results: [SearchResultModel]) -> ())?,
        failure: Failure?) {
        Network.request(target: .search(query: query, offset: offset, size: size, sortType: sortType.rawValue), success: { data in
            let decoder = JSONDecoder()
            guard let response = try? decoder.decode(SearchResponeModel.self, from: data),
                let result = response.result else {
                    failure?("搜索失败")
                    return
            }
            success?(result)
        }, failure: failure)
    }
    
    func ignoreTopic(topicID: String,
                     token: String,
                     success: Action?,
                     failure: Failure?) {
        
    }
    
    func favoriteTopic(topicID: String,
                       token: String,
                       success: Action?,
                       failure: Failure?) {
        Network.htmlRequest(target: .favoriteTopic(topicID: topicID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
    
    func unfavoriteTopic(topicID: String,
                         token: String,
                         success: Action?,
                         failure: Failure?) {
        Network.htmlRequest(target: .unfavoriteTopic(topicID: topicID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
    
    func thankTopic(topicID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?) {
        
    }
}
