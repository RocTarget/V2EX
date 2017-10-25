import UIKit

extension UIViewController {

    public func push(controller: UIViewController, animated: Bool = true) {
        navigationController?.push(controller: controller, animated: animated)
    }

    @discardableResult
    public func pop(animated: Bool = true) -> UIViewController? {
        return navigationController?.popViewController(animated: animated)
    }

    public func popRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

}
