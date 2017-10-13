import Foundation
import UIKit

struct Config {

    static var baseURL = "https://www.v2ex.com"
}


extension UIScreen {
    class var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    class var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
