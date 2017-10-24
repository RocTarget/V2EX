import Foundation
import UIKit

public typealias JSONArray = [[String : Any]]
public typealias JSONDictionary = [String : Any]
public typealias Action = () -> Void

//typealias L10n = R.string.localizable

func presentLoginVC() {
    let nav = NavigationViewController(rootViewController: LoginViewController())
    AppWindow.shared.window.rootViewController?.present(nav, animated: true, completion: nil)
}
