import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: BaseTopicsViewController {
    
    private lazy var tabView: NodeTabView = {
        let view = NodeTabView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: UIScreen.screenWidth,
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
        if let searchField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            searchField.layer.borderWidth = 0.5
            searchField.layer.borderColor = Theme.Color.borderColor.cgColor
            searchField.layer.cornerRadius = 5.0
            searchField.layer.masksToBounds = true
        }
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        
        definesPresentationContext = true
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.titleView = tabView
    }
    
    func tabChangebHandle() {
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }
            
            self.tableView.scrollToTop()
            self.href = self.nodes[index].href
            self.fetchTopic()
        }
    }
    
    private func setupSearchBar() {
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.height)
    }

    override func setupRx() {
        super.setupRx()
        
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
    }
    
    func fetchIndexData() {
        startLoading()
        
        index(success: { [weak self] nodes, topics in
            guard let `self` = self else { return }
            
            self.nodes = nodes
            self.topics = topics
            self.endLoading()
            
            // 避免调用两次请求
            self.tabChangebHandle()
            
            }, failure: { [weak self] error in
                HUD.dismiss()
                self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
                if let `errorView` = self?.errorView as? ErrorView {
                    errorView.message = error
                }
        })
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
