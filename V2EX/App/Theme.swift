import UIKit

struct Theme {
    
    struct Color {
        static let globalColor = #colorLiteral(red: 1, green: 0.1803921569, blue: 0.537254902, alpha: 1) // 全局色
        static let navColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1764705882, alpha: 1)
        static let borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        static let bgColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9647058824, alpha: 1) // 背景颜色
        static let disableColor = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8431372549, alpha: 1)
        static let grayColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1764705882, alpha: 0.4964415668)
        static let textInkyColor = #colorLiteral(red: 0.4235294118, green: 0.4470588235, blue: 0.4509803922, alpha: 1)
    }
    
    struct Font {
        static let body = UIFont.systemFont(ofSize: 16)
        static let small = UIFont.systemFont(ofSize: 14)
        static let heading1 = UIFont.systemFont(ofSize: 28)
        static let heading2 = UIFont.systemFont(ofSize: 24)
        static let heading3 = UIFont.systemFont(ofSize: 18)
    }
}
