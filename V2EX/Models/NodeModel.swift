import Foundation
import UIKit

public struct NodeCategoryModel {
    var id: Int
    var name: String
    var nodes: [NodeModel]
}

public struct NodeModel: Codable {
    var name: String
    var href: String
    var isCurrent: Bool? = false
    var icon: String?
    var comments: String?
    var intro: String?
    var topicNumber: Int?

    private enum CodingKeys: String, CodingKey {
        case name = "title"
        case href = "url"
        case intro = "header"
        case topicNumber = "topics"
        case isCurrent, icon, comments
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