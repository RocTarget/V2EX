import Foundation
import UIKit
import IQKeyboardManagerSwift


struct AppSetup {

    static func prepare() {
        setupKeyboardManager()
        HUD.configureAppearance()
    }
}


// MARK: - didFinishLaunchingWithOptions
extension AppSetup {
    
    /// 键盘自处理
    private static func setupKeyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 70
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        
//        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses = [
//            CreateTopicViewController.self
//        ]
        IQKeyboardManager.sharedManager().disabledToolbarClasses = [
            TopicDetailViewController.self
        ]
        IQKeyboardManager.sharedManager().disabledTouchResignedClasses = [
            TopicDetailViewController.self
        ]
    }
}
