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
    var name: String
    var href: String
    var isCurrent: Bool? = false
    var icon: String?
    var comments: String?
    var intro: String?
    var topicNumber: Int?
    var favoriteHref: String?
    var isFavorite: Bool = false

    private enum CodingKeys: String, CodingKey {
        case name = "title"
        case href = "url"
        case intro = "header"
        case topicNumber = "topics"
        case isCurrent, icon, comments, favoriteHref, isFavorite
    }
    
    var path: String {
        return (try? href.asURL().path) ?? href
    }
    
    var iconFullURL: String? {
        if let `icon` = icon {
            return Constants.Config.URIScheme + icon
        }
        return nil
    }

    public var favoriteOrUnfavoriteHref: String? {
        guard let href = favoriteHref else { return nil }

        if isFavorite, href.hasPrefix("/favorite") {
            return href.replacingOccurrences(of: "/favorite", with: "/unfavorite")
        } else if !isFavorite, href.hasPrefix("/unfavorite") {
            return href.replacingOccurrences(of: "/unfavorite", with: "/favorite")
        } else {
            return href
        }
    }

    init(name: String, href: String, isCurrent: Bool = false) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
    }

    init(name: String, href: String, isCurrent: Bool = false, icon: String?, comments: String?) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
        self.icon = icon
        self.comments = comments
    }

    
    init(name: String, href: String, intro: String?, topicNumber: Int) {
        self.name = name
        self.href = href
        self.intro = intro
        self.topicNumber = topicNumber
    }
    
    static func nodes(data: Data) -> [NodeModel]? {
        return try? JSONDecoder().decode([NodeModel].self, from: data)
    }
}
