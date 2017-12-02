import Foundation

extension String {
    var bang: [String] {
        let locale = CFLocaleCopyCurrent()
        let text = self as CFString
        let range = CFRangeMake(0, CFStringGetLength(text))
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, text, range, UInt(kCFStringTokenizerUnitWordBoundary), locale)
        
        var tokens = [String]()
        CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        while (true) {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            if range.location == kCFNotFound && range.length == 0 { break }
            let token = CFStringCreateWithSubstring(kCFAllocatorDefault, text, range)
            if let item = token as String?, item.trimmed.isNotEmpty {
                tokens.append(item)
            }
            CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        
        return tokens
    }
}
