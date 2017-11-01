import Foundation
import UIKit

public struct NodeCategoryModel: Codable {
    var id: Int
    var name: String
    var nodes: [NodeModel]

    static func save(_ groups: [NodeCategoryModel]) {
        if let enc = try? JSONEncoder().encode(groups) {
            FileManager.save(enc, savePath: Constants.Keys.nodeGroupCache)
        }
    }

    static func get() -> [NodeCategoryModel]? {
        if FileManager.default.fileExists(atPath: Constants.Keys.nodeGroupCache),
            let data = try? Data(contentsOf: URL(fileURLWithPath: Constants.Keys.nodeGroupCache)),
            let model = try? JSONDecoder().decode([NodeCategoryModel].self, from: data),
            model.count.boolValue {
            return model
        }
        return nil
    }
}

public struct NodeModel: Codable {
    /// 节点标题
    var title: String
    /// 节点的路径名字，发布主题时使用 (eg: 沙盒 / sandbox)
    var name: String?
    /// 节点链接
    var href: String
    /// 是否当前选择
    var isCurrent: Bool? = false
    /// 节点图标
    var icon: String?
    var comments: String?
    /// 节点简介
    var intro: String?
    /// 节点下主题个数
    var topicNumber: Int?
    /// 收藏的链接
    var favoriteHref: String?
    /// 是否收藏
    var isFavorite: Bool? = false

    private enum CodingKeys: String, CodingKey {
        case name, title
        case href = "url"
        case intro = "header"
        case topicNumber = "topics"
        case isCurrent, icon, comments, favoriteHref, isFavorite
    }
    
    var path: String {
        return (try? href.asURL().path) ?? href
    }
    
    var iconFullURL: String? {
        guard let `icon` = icon else { return nil }
        // 静态资源，没有 host， 故加上
        return icon.hasPrefix("//v2ex") ? Constants.Config.URIScheme + icon : Constants.Config.baseURL + icon
    }

    public var favoriteOrUnfavoriteHref: String? {
        guard let href = favoriteHref,
            let `isFavorite` = isFavorite else { return nil }

        if isFavorite, href.hasPrefix("/favorite") {
            return href.replacingOccurrences(of: "/favorite", with: "/unfavorite")
        } else if !isFavorite, href.hasPrefix("/unfavorite") {
            return href.replacingOccurrences(of: "/unfavorite", with: "/favorite")
        } else {
            return href
        }
    }

    init(title: String, href: String, isCurrent: Bool = false) {
        self.title = title
        self.href = href
        self.isCurrent = isCurrent
    }

    init(title: String, href: String, isCurrent: Bool = false, icon: String?, comments: String?) {
        self.title = title
        self.href = href
        self.isCurrent = isCurrent
        self.icon = icon
        self.comments = comments
    }

    
    init(title: String, href: String, intro: String?, topicNumber: Int) {
        self.title = title
        self.href = href
        self.intro = intro
        self.topicNumber = topicNumber
    }
    
    static func nodes(data: Data) -> [NodeModel]? {
        do {
            return try JSONDecoder().decode([NodeModel].self, from: data)
        } catch {
            log.error(error)
            return nil
        }
    }
}
