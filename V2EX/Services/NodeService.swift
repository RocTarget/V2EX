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
    
    
    /// 获取我收藏的节点
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func myNodes(
        success: ((_ nodes: [NodeModel]) -> Void)?,
        failure: Failure?)
    
    /// 所有节点
    ///
    /// - Parameters:
    ///   - success: 成功
    ///   - failure: 失败
    func nodes(
        success: @escaping ((_ groups: [NodeCategoryModel]) -> Void),
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
        Network.htmlRequest(target: .topics(href: node.path), success: { html in
            
            //            let nodeIcon = html.xpath("//*[@id='Main']//div[@class='header']/div/img").first?["src"]
            //            let nodeIntro = html.xpath("//*[@id='Main']//div[@class='header']/span[last()]").first?.content
            //            let topicNumber = html.xpath("//*[@id='Main']//div[@class='header']/div[2]/strong").first?.content
            //            var `node` = node
            //            node.icon = nodeIcon
            //            node.intro = nodeIntro
            //            node.topicNumber = topicNumber
            
            var `node` = node
            if let nodename = html.xpath("//*[@id='Wrapper']//div[@class='header']/text()[2]").first?.text?.trimmed {
                node.name = nodename
            }
            let topics = self.parseTopic(html: html, type: .nodeDetail)
            success?(node, topics)
        }, failure: failure)
    }
    
    func myNodes(
        success: ((_ nodes: [NodeModel]) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .myNodes, success: { html in
            let nodes = html.xpath("//*[@id='MyNodes']/a/div").flatMap({ (ele) -> NodeModel? in
                guard let imageSrc = ele.xpath("./img").first?["src"],
                    let comment = ele.xpath("./span").first?.content,
                    let name = ele.parent?.xpath("./div/text()").first?.content,
                    let href = ele.parent?["href"] else {
                        return nil
                }
                return NodeModel(name: name, href: href, icon: imageSrc, comments: comment)
            })
            success?(nodes)
        }, failure: failure)
    }
    
    func nodes(
        success: @escaping ((_ groups: [NodeCategoryModel]) -> Void),
        failure: Failure?) {
        Network.request(target: .nodes, success: { data in
            guard let nodes = NodeModel.nodes(data: data) else {
                failure?("数据解析失败")
                return
            }
            self.nodeSort(nodes, complete: success)
        }, failure: failure)
//        Network.htmlRequest(target: .nodes, success: { html in
//            let nodesPath = html.xpath("//*[@id='Wrapper']/div/div[@class='box']/div[@class='inner']/a")
//            let nodes = nodesPath.flatMap({ ele -> NodeModel? in
//                guard let nodename = ele.content,
//                    let nodeHref = ele["href"] else {
//                        return nil
//                }
//                return NodeModel(name: nodename, href: nodeHref)
//            })
//            success?(nodes)
//        }, failure: failure)
    }
    
    
    /// 将所有 node 排序成组
    ///
    /// - Parameters:
    ///   - nodes: nodes
    ///   - complete: 完成
    private func nodeSort(_ nodes: [NodeModel], complete: @escaping ((_ nodeGroup: [NodeCategoryModel]) -> Void )) {
        guard nodes.count > 0 else { return }

        GCD.runOnBackgroundThread {

            var `nodes` = nodes

            let tempInitial = nodes[0].name.pinYingString.firstLetter
            let currentGroup = NodeCategoryModel(id: 0, name: tempInitial, nodes: [])
            var group: [NodeCategoryModel] = [currentGroup]

            var otherGroup = NodeCategoryModel(id: 0, name: "#", nodes: [])

            for node in nodes {
                let initial = node.name.pinYingString.firstLetter

                //  不放在其他组, 单独一组, 谁让我是果粉 😀
                if initial != "", !self.isLetter(string: initial) {
                    otherGroup.nodes.append(node)
                    continue
                }

                if let index = group.index(where: { $0.name == initial }) {
                    group[index].nodes.append(node)
                    continue
                }

                group.append(NodeCategoryModel(id: 0, name: initial, nodes: [node]))
            }

            if otherGroup.nodes.count.boolValue {
                group.append(otherGroup)
            }

            group.sort { (lhs, rhs) -> Bool in
                return lhs.name < rhs.name
            }

            GCD.runOnMainThread {
                complete(group)
            }
        }
    }
    
    // 判断是否为字母
    private func isLetter(string: String) -> Bool {
        if string.count == 0 {return false}
        let index = string.index(string.startIndex, offsetBy: 1)
        let regextest = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z]+$")
        return regextest.evaluate(with: string[..<index])
    }
}
