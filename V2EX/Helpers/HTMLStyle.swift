import Foundation

struct HTMLStyle {

    var cssString: String = ""

    private init() {
        do {
            cssString = try String(contentsOf: R.file.styleCss()!)
        } catch {
            log.error("CSS 加载失败")
        }
    }
}
