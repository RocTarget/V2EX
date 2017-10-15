import Foundation

public struct NodeCategoryModel {
    var id: Int
    var name: String
    var nodes: [NodeModel]
}

public struct NodeModel {
    var name: String
    var href: String
    var isCurrent: Bool = false
    var icon: String?
    var comments: Int?
    var intro: String?
    var topicNumber: String?

    init(name: String, href: String, isCurrent: Bool = false) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
    }

    init(name: String, href: String, isCurrent: Bool = false, icon: String?, comments: Int?) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
        self.icon = icon
        self.comments = comments
    }

    
    init(name: String, href: String, intro: String?, topicNumber: String) {
        self.name = name
        self.href = href
        self.intro = intro
        self.topicNumber = topicNumber
    }
}
