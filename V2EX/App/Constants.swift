import Foundation
import UIKit

struct Constants {

    struct Config {
        // App
        static var baseURL = "https://www.v2ex.com"
    }

    struct Keys {
        // User 登录用户名
        static let username = "username"
    }
}


extension UIScreen {
    class var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    class var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
