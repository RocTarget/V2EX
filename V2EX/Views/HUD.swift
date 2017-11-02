import Foundation
import PKHUD
import Toaster

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
        let appearance = ToastView.appearance()
        appearance.font = .boldSystemFont(ofSize: 16)
        appearance.textInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
    
    class func show() {
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
        PKHUD.sharedHUD.contentView = CustomHUD(image: #imageLiteral(resourceName: "hud_progress"))
        PKHUD.sharedHUD.show(onView: UIApplication.shared.windows.last)
    }

    class func dismiss() {
//        PKHUD.sharedHUD.hide(false)
        PKHUD.sharedHUD.hide()
    }

    class func showSuccess(_ text: String, delay: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, delay: delay, completionBlock: completionBlock)
    }

    class func showError(_ text: String, delay: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, delay: delay, completionBlock: completionBlock)
    }

    class func showWarning(_ text: String, delay: TimeInterval = 3, completionBlock: Action? = nil) {
        showText(text, delay: delay, completionBlock: completionBlock)
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

    class func showText(_ text: String, delay: TimeInterval = 3, completionBlock: Action? = nil) {
        Toast(text: text, delay: 0, duration: delay).show()
        GCD.delay(delay) {
            completionBlock?()
        }
    }
}
