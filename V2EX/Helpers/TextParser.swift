import Foundation
import UIKit
import YYText

//    "<([^>]*)>"; // 过滤所有以<开头以>结尾的标签
//    "<\\s*img\\s+([^>]*)\\s*>"; // 找出IMG标签
//    "src=\"([^\"]+)\""; // 找出IMG标签的SRC属性
struct TextParser {

    static var mentioned: NSRegularExpression? {
        return try? NSRegularExpression(pattern: "@(\\S+)\\s", options: [.caseInsensitive])
    }
    
    static var iframe: NSRegularExpression? {
        return try? NSRegularExpression(pattern: "<iframe(.*?)</iframe>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    }

    static var imgTag: NSRegularExpression? {
        return try? NSRegularExpression(pattern: "<img src=(.*?)>", options: [.caseInsensitive, .dotMatchesLineSeparators])
    }

    /// 正则：匹配 www.a.com 或者 http://www.a.com 的类型
    /// ref: http://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
    static var regexURLs: NSRegularExpression? {
        get {
            let regex: String = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|^[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*"
            let regularExpression = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        }
    }
}

private extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)
        let to = range.upperBound.samePosition(in: utf16view)
        return NSRange(location: utf16view.distance(from: utf16view.startIndex, to: from!), length: utf16view.distance(from: from!, to: to!))
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}


