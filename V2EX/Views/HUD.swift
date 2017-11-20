import Foundation
import PKHUD
import Toaster
import RxSwift
import RxCocoa
import NSObject_Rx

private class CustomHUD: PKHUDRotatingImageView {

    static let defaultFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0))

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(image: UIImage?, title: String? = nil, subtitle: String? = nil) {
        super.init(image: image, title: title, subtitle: subtitle)
        self.frame = CustomHUD.defaultFrame
        self.imageView.contentMode = .scaleAspectFit
    }
}

final class HUD {
    
    class func configureAppearance() {
        // Optimize: 页面模式变 白低黑字
        let appearance = ToastView.appearance()
        appearance.font = .boldSystemFont(ofSize: 16)
        appearance.textInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
    
    class func show() {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
        PKHUD.sharedHUD.contentView = CustomHUD(image: #imageLiteral(resourceName: "hud_progress"))

        PKHUD.sharedHUD.show(onView: UIApplication.shared.keyWindow)
        //        PKHUD.sharedHUD.show(onView: UIApplication.shared.windows.last)
//        PKHUD.sharedHUD.show(onView: UIApplication.shared.windows[UIApplication.shared.windows.count - 1])
    }

    class func dismiss() {
//        PKHUD.sharedHUD.hide(false)
        PKHUD.sharedHUD.hide()
    }

    class func showSuccess(_ text: String, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, duration: duration, completionBlock: completionBlock)
    }

    class func showError(_ text: String, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, duration: duration, completionBlock: completionBlock)
    }

    class func showError(_ error: Error, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(error.localizedDescription, duration: duration, completionBlock: completionBlock)
    }

    class func showWarning(_ text: String, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, duration: duration, completionBlock: completionBlock)
    }

    /// 测试使用
    class func showTest(_ text: String) {
        #if DEBUG
            Toast(text: "[Debug]: \(text)", delay: 0, duration: 3).show()
        #endif
    }

    /// 测试使用
    class func showTest(_ error: Error) {
        showTest(error.localizedDescription)
    }

    class func showText(_ text: String, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        Toast(text: text, delay: 0, duration: duration).show()
        GCD.delay(duration) {
            completionBlock?()
        }
    }

    class func showText(_ error: Error, duration: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(error.localizedDescription, duration: duration, completionBlock: completionBlock)
    }
}
