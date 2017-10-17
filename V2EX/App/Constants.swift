import Foundation
import UIKit

struct Constants {

    struct Config {
        // App
        static var baseURL = "https://www.v2ex.com"

        static var URIScheme = "https:"
    }

    struct Keys {
        // User 登录时的用户名
        static let loginAccount = "loginAccount"
        
        // User 持久化
        static let userInfo = "UserInfo"
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
