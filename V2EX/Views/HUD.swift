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
        PKHUD.sharedHUD.contentView = CustomHUD(image: Asset.hud_progress())
        PKHUD.sharedHUD.show(onView: UIApplication.shared.windows.last)
    }

    class func dismiss() {
//        PKHUD.sharedHUD.hide(false)
        PKHUD.sharedHUD.hide()
    }

//    class func showSuccess(_ text: String? = nil) {
//        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
//        PKHUD.HUD.flash(.labeledSuccess(title: nil, subtitle: text), onView: UIApplication.shared.windows.last, delay: 3)
//    }

    class func showText(_ text: String, delay: TimeInterval = 3) {
        
        Toast(text: text, delay: 0, duration: delay).show()
        
//        PKHUD.sharedHUD.effect = UIBlurEffect(style: .extraLight)
//        PKHUD.HUD.flash(.label(text), onView: UIApplication.shared.windows.last, delay: delay)
    }
}
