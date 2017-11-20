import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController, AccountService, TopicService {

    private lazy var tabView: NodeTabView = {
        let view = NodeTabView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: Constants.Metric.screenWidth - 50,
                          height: self.navigationController!.navigationBar.height),
            nodes: nodes)
        return view
    }()

    var nodes: [NodeModel] = [] {
        didSet {
            tabView.nodes = nodes
        }
    }

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
//        scrollView.frame = self.view.bounds
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        return scrollView
    }()

    private lazy var searchResultVC: TopicSearchResultViewController = {
        let view = TopicSearchResultViewController()
        return view
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchResultVC)
        searchController.searchBar.placeholder = "搜索主题"
        searchController.searchBar.scopeButtonTitles = ["权重", "时间"]
        searchController.searchBar.tintColor = Theme.Color.globalColor
        searchController.searchBar.barTintColor = Theme.Color.bgColor
        // SearchBar 边框颜色
        searchController.searchBar.layer.borderWidth = 0.5
        searchController.searchBar.layer.borderColor = Theme.Color.bgColor.cgColor
        searchController.searchBar.sizeToFit()
        // TextField 边框颜色
        //        if let searchField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
        //            searchField.layer.borderWidth = 0.5
        //            searchField.layer.borderColor = Theme.Color.borderColor.cgColor
        //            searchField.layer.cornerRadius = 5.0
        //            searchField.layer.masksToBounds = true
        //        }
        return searchController
    }()

    // MARK: - View Life Cycle...
    override func viewDidLoad() {
        super.viewDidLoad()

        listenNotification()
        fetchData()
    }

    override func setupSubviews() {
        super.setupSubviews()

        navigationItem.titleView = tabView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "search"), style: .plain) { [weak self] in
            let nav = NavigationViewController(rootViewController: TopicSearchResultViewController())
            self?.present(nav, animated: true, completion: nil)
        }
    }

    func tabChangebHandle() {
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }
            var offset = self.scrollView.contentOffset
            let offsetX = self.scrollView.width * index.f
            offset.x = offsetX
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }

    private func fetchData() {

        nodes = homeNodes()
        tabChangebHandle()

        scrollView.contentSize = CGSize(width: nodes.count.f * scrollView.width, height: scrollView.contentSize.height)
        for node in nodes {
            let topicVC = BaseTopicsViewController()
            topicVC.href = node.href
            addChildViewController(topicVC)
        }
        GCD.delay(0.05) {
            self.scrollViewDidEndScrollingAnimation(self.scrollView)
        }
    }

    private func dailyRewardMission() {
        guard AccountModel.isLogin else { return }

        dailyReward(success: { days in
            GCD.delay(0.3, block: {
                HUD.showText(days)
            })
        }) { error in
            // Optimize: 提示用户可以下拉刷新重新领取
            HUD.showTest(error)
            log.error(error)
        }
    }

    private func listenNotification() {

        NotificationCenter.default.rx
            .notification(Notification.Name.V2.TwoStepVerificationName)
            .subscribeNext { [weak self] _ in
                let twoStepVer = TwoStepVerificationViewController()
                let nav = NavigationViewController(rootViewController: twoStepVer)
                self?.present(nav, animated: true, completion: nil)
            }.disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(Notification.Name.V2.LoginSuccessName)
            .subscribeNext { [weak self] _ in
                self?.dailyRewardMission()
            }.disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(Notification.Name.V2.DidSelectedHomeTabbarItemName)
            .subscribeNext { [weak self] _ in
                guard let `self` = self else { return }
                let willShowVC = self.childViewControllers[self.tabView.selectIndex]
                if let scrollView = willShowVC.view.subviews.first as? UIScrollView {
                    scrollView.scrollToTop()
                }
            }.disposed(by: rx.disposeBag)
    }
}



extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / scrollView.width)

        tabView.setSelectIndex(index)

        let willShowVC = childViewControllers[index]

        if willShowVC.isViewLoaded { return }
        willShowVC.view.frame = scrollView.bounds
        scrollView.addSubview(willShowVC.view)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
}
