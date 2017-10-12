import Foundation

struct NodeModel {
    var name: String?
    var href: String?
    var isCurrent: Bool = false
    var icon: String?
    var comments: Int?

    init(name: String?, href: String?, isCurrent: Bool = false) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
    }

    init(name: String?, href: String?, isCurrent: Bool = false, icon: String?, comments: Int?) {
        self.name = name
        self.href = href
        self.isCurrent = isCurrent
        self.icon = icon
        self.comments = comments
    }

}
