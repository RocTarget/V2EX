import Foundation
import UIKit

public typealias JSONArray = [[String : Any]]
public typealias JSONDictionary = [String : Any]
public typealias Action = () -> Void

//typealias L10n = R.string.localizable
typealias Asset = R.image

func presentLoginVC() {
    let nav = NavigationViewController(rootViewController: LoginViewController())
    AppDelegate.shared.window?.rootViewController?.present(nav, animated: true, completion: nil)
}
