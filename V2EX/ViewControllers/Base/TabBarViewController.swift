import UIKit
import RxSwift
import RxCocoa
import RxOptional

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setupTabBar()
        clickBackTop()
    }
}

extension TabBarViewController {
    
    fileprivate func setAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : Theme.Color.navColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : Theme.Color.globalColor], for: .selected)
    }
    
    fileprivate func setupTabBar() {
        addChildViewController(childController: HomeViewController(),
                               title: "首页",
                               normalImage: nil,
                               selectedImageName: nil)
//
//        addChildViewController(childController: R.storyboard.contact.contactViewController()!,
//                               title: R.string.localizable.systemMainLongdistance(),
//                               normalImage: R.image.content_icon_longdistance_normal(),
//                               selectedImageName: R.image.content_icon_longdistance_selected())
//        
//        addChildViewController(childController: PatternsViewController(),
//                               title: R.string.localizable.systemMainPatterns(),
//                               normalImage: R.image.content_icon_pattern_normal(),
//                               selectedImageName: R.image.content_icon_pattern_selected())
    }
    
    fileprivate func addChildViewController(childController: UIViewController, title: String, normalImage: UIImage?, selectedImageName: UIImage?) {
        childController.tabBarItem.image = normalImage?.withRenderingMode(.alwaysOriginal)
        childController.tabBarItem.selectedImage = selectedImageName?.withRenderingMode(.alwaysOriginal)
        childController.title = title
        childController.navigationItem.title = nil
        let nav = NavigationViewController(rootViewController: childController)
        addChildViewController(nav)
    }
    
    fileprivate func clickBackTop() {
        self.rx.didSelect
            .scan((nil, nil)) { state, viewController in
                return (state.1, viewController)
            }
            // 如果第一次选择视图控制器或再次选择相同的视图控制器
            .filter { state in state.0 == nil || state.0 === state.1 }
            .map { state in state.1 }
            .filterNil()
            .subscribe(onNext: { [weak self] viewController in
                self?.scrollToTop(viewController) // scroll to top
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    fileprivate func scrollToTop(_ viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            let topViewController = navigationController.topViewController
            let firstViewController = navigationController.viewControllers.first
            if let viewController = topViewController, topViewController === firstViewController {
                self.scrollToTop(viewController)
            }
            return
        }
        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
        scrollView.setContentOffset(.zero, animated: true)
    }
}
