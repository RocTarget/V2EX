import Foundation
import Kanna

protocol TopicService {


    /// 获取 首页 数据
    ///
    /// - Parameters:
    ///   - success: 成功返回 nodes, topics, navigations
    ///   - failure: 失败
    func index(
        success: ((_ nodes: NodeModel, _ topics: TopicModel) -> Void)?,
        failure: Failure?)

    /// 获取 首页 主题数据
    ///
    /// - Parameters:
    ///   - href: href
    ///   - success: 成功返回 topics
    ///   - failure: 失败
    func topics(
        href: String,
        success: ((_ topics: TopicModel) -> Void)?,
        failure: Failure?)
}

extension TopicService {
    func index(
        success: ((_ nodes: NodeModel, _ topics: TopicModel) -> Void)?,
        failure: Failure?) {
        Networking.shared.htmlRequest(target: .topics(href: nil), success: { html in
            log.info(html)
        }, failure: failure)
    }

    func topics(
        href: String,
        success: ((_ topics: TopicModel) -> Void)?,
        failure: Failure?) {
        index(success: { (_, topics) in
            success?(topics)
        }, failure: failure)
    }
}
