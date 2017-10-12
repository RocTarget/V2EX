import Foundation
import UIKit


struct AppSetup {

    static func setup() {
        setupWindow()
    }
}


// MARK: - didFinishLaunchingWithOptions
extension AppSetup {

    /// 设置根窗口
    private static func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        window.setCornerRadius = 5
        window.makeKeyAndVisible()
        AppDelegate.shared.window = window

        window.rootViewController = TabBarViewController()
    }
}
