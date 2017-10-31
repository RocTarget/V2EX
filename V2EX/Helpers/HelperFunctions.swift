import Foundation
import UIKit
import SKPhotoBrowser

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
    let photoBrowser = SKPhotoBrowser(photos: [photoItem])
    photoBrowser.initializePageIndex(0)
    photoBrowser.showToolbar(bool: true)
    AppWindow.shared.window.rootViewController?.present(photoBrowser, animated: true, completion: nil)
}
