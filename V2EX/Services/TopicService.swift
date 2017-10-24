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
        topicID: String,
        success: ((_ topic: TopicModel, _ comments: [CommentModel]) -> Void)?,
        failure: Failure?)
    
    /// 发布评论
    ///
    /// - Parameters:
    ///   - once: 凭证
    ///   - topicID: 主题 id
    ///   - content: 回复内容
    ///   - success: 成功
    ///   - failure: 失败
    func comment(
        once: String,
        topicID: String,
        content: String,
        success: Action?,
        failure: Failure?)
    
    /// 创建主题
    ///
    /// - Parameters:
    ///   - nodename: 节点名称
    ///   - title: 主题标题
    ///   - body: 主题正文
    ///   - success: 成功
    ///   - failure: 失败
    func createTopic(
        nodename: String,
        title: String,
        body: String?,
        success: Action?,
        failure: @escaping Failure)
    
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
        success: ((_ messages: [MessageModel]) -> ())?,
        failure: Failure?)
    
    /// 搜索主题
    ///
    /// - Parameters:
    ///   - query: 关键字
    ///   - offset: 偏移量
    ///   - size: 一页大小
    ///   - sortType: 排序类型
    ///   - success: 成功
    ///   - failure: 失败
    func search(
        query: String,
        offset: Int,
        size: Int,
        sortType: SearchSortType,
        success: ((_ results: [SearchResultModel]) -> ())?,
        failure: Failure?)
    
    /// 忽略主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - once: 凭证
    ///   - success: 成功
    ///   - failure: 失败
    func ignoreTopic(topicID: String,
                     once: String,
                     success: Action?,
                     failure: Failure?)
    
    /// 收藏主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func favoriteTopic(topicID: String,
                       token: String,
                       success: Action?,
                       failure: Failure?)
    
    /// 取消收藏主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func unfavoriteTopic(topicID: String,
                         token: String,
                         success: Action?,
                         failure: Failure?)
    
    /// 感谢主题
    ///
    /// - Parameters:
    ///   - topicID: 主题id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func thankTopic(topicID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?)
    
    /// 感谢回复
    ///
    /// - Parameters:
    ///   - replyID: 回复id
    ///   - token: token
    ///   - success: 成功
    ///   - failure: 失败
    func thankReply(replyID: String,
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

                    // TODO: 领取奖励
                    /// 领取今日的登录奖励
                    if let dailyNode = html.xpath("//*[@id='Wrapper']/div[@class='content']/div[1]/div[@class='inner']/a[@href='/mission/daily']").first,
                        dailyNode.content == "领取今日的登录奖励" {

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
            
            let comments = self.parseComment(html: html)

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

                // 如果是登录状态 检查是否已经感谢和收藏
                if AccountModel.isLogin {
                    topic.isFavorite = isFavorite
                    let thankStr = html.xpath("//*[@id='topic_thank']").first?.content ?? ""
                    topic.isThank = thankStr != "感谢"
                }
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
            success?(self.parseMemberTopics(html: html))
        }, failure: failure)
    }
    
    func memberReplys(
        username: String,
        success: ((_ messages: [MessageModel]) -> ())?,
        failure: Failure?) {
        Network.htmlRequest(target: .memberReplys(username: username), success: { html in
            success?(self.parseMemberReplys(html: html))
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
                     once: String,
                     success: Action?,
                     failure: Failure?) {
        Network.htmlRequest(target: .ignoreTopic(topicID: topicID, once: once), success: { html in
            success?()
        }, failure: failure)
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
        Network.htmlRequest(target: .thankTopic(topicID: topicID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
    
    func thankReply(replyID: String,
                    token: String,
                    success: Action?,
                    failure: Failure?) {
        Network.htmlRequest(target: .thankReply(replyID: replyID, token: token), success: { html in
            success?()
        }, failure: failure)
    }
}
