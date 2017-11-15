import Foundation
import UIKit
import SKPhotoBrowser
import SafariServices

public typealias JSONArray = [[String : Any]]
public typealias JSONDictionary = [String : Any]
public typealias Action = () -> Void

//typealias L10n = R.string.localizable

func presentLoginVC() {
    let nav = NavigationViewController(rootViewController: LoginViewController())
    AppWindow.shared.window.rootViewController?.present(nav, animated: true, completion: nil)
}

enum PhotoBrowserType {
    case image(UIImage)
    case imageURL(String)
}

func showImageBrowser(imageType: PhotoBrowserType) {

    var photo: SKPhoto?
    switch imageType {
    case .image(let image):
        photo = SKPhoto.photoWithImage(image)
    case .imageURL(let url):
        photo = SKPhoto.photoWithImageURL(url)
        photo?.shouldCachePhotoURLImage = true
    }
    guard let photoItem = photo else { return }
    SKPhotoBrowserOptions.bounceAnimation = true
    SKPhotoBrowserOptions.enableSingleTapDismiss = true
    SKPhotoBrowserOptions.displayCloseButton = false
    let photoBrowser = SKPhotoBrowser(photos: [photoItem])
    photoBrowser.initializePageIndex(0)
    photoBrowser.showToolbar(bool: true)
    AppWindow.shared.window.rootViewController?.present(photoBrowser, animated: true, completion: nil)
}

/// 设置状态栏背景颜色
/// 需要设置的页面需要重载此方法
/// - Parameter color: 颜色
func setStatusBarBackground(_ color: UIColor) {
    
    let statusBarWindow : UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
    let statusBar : UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
    if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
        statusBar.backgroundColor = color
    }
}

/// 打开浏览器 （内置 或 Safari）
///
/// - Parameter url: url
func openWebView(url: URL?) {
    guard let `url` = url else { return }

    let openWithSafariBrowser = (UserDefaults.get(forKey: Constants.Keys.openWithSafariBrowser) as? Bool ?? false)

    if openWithSafariBrowser {

        let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: true) //SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            safariVC.preferredControlTintColor = Theme.Color.globalColor
        } else {
            safariVC.navigationController?.navigationBar.tintColor = Theme.Color.globalColor
        }
        AppWindow.shared.window.rootViewController?.present(safariVC, animated: true, completion: nil)
        return
    }
    if let nav = AppWindow.shared.window.rootViewController?.currentViewController().navigationController {
        let webView = SweetWebViewController()
        webView.url = url
        nav.pushViewController(webView, animated: true)
    } else {
        let safariVC = SFSafariViewController(url: url)
        AppWindow.shared.window.rootViewController?.present(safariVC, animated: true, completion: nil)
    }
}

func openWebView(url: String) {
    guard let `url` = URL(string: url) else { return }
    openWebView(url: url)
}
