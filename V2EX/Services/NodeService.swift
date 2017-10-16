import Foundation
import Kanna

protocol NodeService: HTMLParseService {
    
    
    /// 获取节点导航
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func nodeNavigation(
        success: ((_ nodeCategorys: [NodeCategoryModel]) -> Void)?,
        failure: Failure?)
    
    
    /// 获取指定节点的详情和主题
    ///
    /// - Parameters:
    ///   - node: node
    ///   - success: 成功
    ///   - failure: 失败
    func nodeDetail(
        node: NodeModel,
        success: ((_ node: NodeModel, _ topics: [TopicModel]) -> Void)?,
        failure: Failure?)
}

extension NodeService {
    
    func nodeNavigation(
        success: ((_ nodeCategorys: [NodeCategoryModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .topics(href: nil), success: { html in
            let cates = self.parseNodeNavigation(html: html)
            success?(cates)
        }, failure: failure)
    }
    
    
    func nodeDetail(
        node: NodeModel,
        success: ((_ node: NodeModel, _ topics: [TopicModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .topics(href: node.href), success: { html in

//            let nodeIcon = html.xpath("//*[@id='Main']//div[@class='header']/div/img").first?["src"]
//            let nodeIntro = html.xpath("//*[@id='Main']//div[@class='header']/span[last()]").first?.content
//            let topicNumber = html.xpath("//*[@id='Main']//div[@class='header']/div[2]/strong").first?.content
//            var `node` = node
//            node.icon = nodeIcon
//            node.intro = nodeIntro
//            node.topicNumber = topicNumber

            let rootPath = html.xpath("//*[@id='Wrapper']/div[@class='content']//div[contains(@class, 'cell')]")
            let topics = self.parseTopic(rootPath: rootPath)
            success?(node, topics)
        }, failure: failure)
    }
}
