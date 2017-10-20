import UIKit

class Dialog {


    @discardableResult
    class func showAlert(title: String = "",
                         subTitle: String,
                         cancelTitle: String = "取消",
                         confirmTitle: String = "确定",
                         handle: (() -> Void)? ) -> Flea {
        let dialog = Flea(type: .alert(title: title, subTitle: subTitle))
        dialog.addAction(cancelTitle, color: .black, action: nil)
        dialog.addAction(confirmTitle, color: .white, action: handle)
        dialog.show()
        return dialog
    }

    @discardableResult
    class func actionSheet() -> Flea {
        return Flea(type: .actionSheet(title: nil, subTitle: nil))
    }

    @discardableResult
    class func actionSheet(title: String, subTitle: String) -> Flea {
        return Flea(type: .actionSheet(title: title, subTitle: subTitle))
    }

    @discardableResult
    class func showNotice(title: String, colorType: DialogColor, duration: TimeInterval = 2) -> Flea {
        let defaultNotificationFlea = Flea(type: .notification(seat: .status, title: title))
        defaultNotificationFlea.style = .normal(colorType.color)
        defaultNotificationFlea.baseAt(AppDelegate.shared.window).stay(duration).show()
        return defaultNotificationFlea
    }

    @discardableResult
    class func showNotice(title: String, colorType: DialogColor, duration: TimeInterval = 2, at navigation: UINavigationController) -> Flea {
        let notificationFlea = Flea(type: .notification(seat: .navigationButtom, title: title))
        notificationFlea.titleColor = UIColor.white
        notificationFlea.style = .normal(colorType.color)
        notificationFlea.baseAt(navigation).stay(duration).show()
        return notificationFlea
    }

    class func showErrorNotice(title: String, duration: TimeInterval = 3) {
        showNotice(title: title, colorType: .error, duration: duration)
    }

    class func showWarningNotice(title: String, duration: TimeInterval = 3) {
        showNotice(title: title, colorType: .warning, duration: duration)
    }

    class func showSuccessNotice(title: String, duration: TimeInterval = 2) {
        showNotice(title: title, colorType: .success, duration: duration)
    }
}

enum DialogColor {
    case custom(UIColor)
    case error
    case success
    case warning

    var color: UIColor {
        switch self {
        case .custom(let color):
            return color
        case .error:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .success:
//            return #colorLiteral(red: 0.368627451, green: 0.8196078431, blue: 0.3882352941, alpha: 1)
            return #colorLiteral(red: 0.3333333333, green: 0.6, blue: 0.2549019608, alpha: 1)
        case .warning:
            return #colorLiteral(red: 0.9450980392, green: 0.768627451, blue: 0.05882352941, alpha: 1)
        }
    }
}
