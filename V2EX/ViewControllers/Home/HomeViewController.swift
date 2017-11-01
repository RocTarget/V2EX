import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: BaseTopicsViewController, AccountService {
    
    private lazy var tabView: NodeTabView = {
        let view = NodeTabView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: Constants.Metric.screenWidth,
                          height: self.navigationController!.navigationBar.height),
            nodes: nodes)
        return view
    }()
    
    var nodes: [NodeModel] = [] {
        didSet {
            tabView.nodes = nodes
        }
    }
    
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
        
        setupSearchBar()
        
        definesPresentationContext = true

        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreTopic()
        }

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
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.titleView = tabView
    }
    
    func tabChangebHandle() {
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }
            self.tableView.scrollToTop()
            let node = self.nodes[index]
            self.href = node.href
            self.fetchTopic()
        }
    }
    
    private func setupSearchBar() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.height)
    }

    override func setupRx() {
        
        searchController.searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext({ [weak searchResultVC, weak searchController] query in
                guard let `searchController` = searchController else { return }
                searchResultVC?.search(query: query, selectedScope: searchController.searchBar.selectedScopeButtonIndex)
            }).disposed(by: rx.disposeBag)
        
        searchController.searchBar.rx
            .selectedScopeButtonIndex
            .distinctUntilChanged()
            .filter { _ in (self.searchController.searchBar.text ?? "").trimmed.isNotEmpty }
            .subscribeNext { [weak searchResultVC, weak searchController] index in
                guard let `searchController` = searchController else { return }
                guard let query = searchController.searchBar.text else { return }
                searchResultVC?.search(query: query, selectedScope: searchController.searchBar.selectedScopeButtonIndex)
            }.disposed(by: rx.disposeBag)

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
                self?.searchController.searchBar.barStyle = theme == .day ? .default : .black
                self?.searchController.searchBar.barTintColor = theme.bgColor
                self?.searchController.searchBar.layer.borderColor = theme.bgColor.cgColor
            }.disposed(by: rx.disposeBag)
    }
    
    private func fetchIndexData() {
        startLoading()

        index(success: { [weak self] nodes, topics, rewardable in
            guard let `self` = self else { return }

            if rewardable { self.dailyRewardMission() }

            self.nodes = nodes
            self.topics = topics
            self.endLoading()

            // 避免调用两次请求
            self.tabChangebHandle()
            
            }, failure: { [weak self] error in
                HUD.dismiss()
                self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
                self?.errorMessage = error
        })
    }

    private func fetchMoreTopic() {
        let href = nodes[tabView.selectIndex].href
        let allHref = "/?tab=all"
        let isAllowRefresh = href.hasPrefix(allHref)
        if isAllowRefresh == false {
            tableView.endFooterRefresh(showNoMore: !isAllowRefresh)
        }

        guard isAllowRefresh else { return }

        recentTopics(page: page, success: { [weak self] topics, maxPage in
            guard let `self` = self else { return }
            self.page += 1
            self.maxPage = maxPage
            self.topics.append(contentsOf: topics)
            self.tableView.endFooterRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
        }
    }

    private func dailyRewardMission() {
        guard AccountModel.isLogin else { return }
        
        dailyReward(success: { days in
            HUD.showText(days)
        }) { error in
            log.error(error)
        }
    }

    override func loadData() {
        fetchIndexData()
    }
    
    override func hasContent() -> Bool {
        return nodes.count.boolValue
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        if nodes.count == 0 {
            fetchIndexData()
        } else {
            startLoading()
            fetchTopic()
        }
    }
}
