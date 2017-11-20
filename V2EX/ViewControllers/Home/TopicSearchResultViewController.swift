import UIKit
import RxSwift
import RxCocoa

class TopicSearchResultViewController: DataViewController, TopicService {

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索主题"
        searchBar.scopeButtonTitles = ["权重", "时间"]
        searchBar.tintColor = Theme.Color.globalColor
        searchBar.barTintColor = ThemeStyle.style.value.bgColor
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        return searchBar
    }()


    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(cellWithClass: TopicSearchResultCell.self)
        tableView.hideEmptyCells()
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        self.view.addSubview(tableView)
        return tableView
    }()
    
    private var searchResults: [SearchResultModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var isSearched = false
    
    private var offset = 0
    private var size = 20
    
    private var query: String?

    private var sortType: SearchSortType = .sumup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
        status = .noSearchResult

        definesPresentationContext = true

        searchBar.becomeFirstResponder()
    }
    
    override func setupSubviews() {

        tableView.addFooterRefresh { [weak self] in
            self?.fecthResult()
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setupRx() {

        searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribeNext { [weak self] query in
                guard let `self` = self else { return }
                self.search(query: query, selectedScope: self.searchBar.selectedScopeButtonIndex)
        }.disposed(by: rx.disposeBag)

        searchBar.rx
            .selectedScopeButtonIndex
            .distinctUntilChanged()
            .filter { _ in (self.searchBar.text ?? "").trimmed.isNotEmpty }
            .subscribeNext { [weak self] index in
                guard let `self` = self else { return }
                guard let query = self.searchBar.text else { return }

                self.searchBar.resignFirstResponder()
                self.search(query: query, selectedScope: self.searchBar.selectedScopeButtonIndex)
            }.disposed(by: rx.disposeBag)

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
//                self?.searchBar.barTintColor = theme.bgColor
                self?.searchBar.tintColor = theme.globalColor
                self?.searchBar.barStyle = theme == .day ? .default : .black
                self?.searchBar.keyboardAppearance = theme == .day ? .default : .dark
            }.disposed(by: rx.disposeBag)

        Observable.of(NotificationCenter.default.rx.notification(.UIKeyboardWillHide),
                      NotificationCenter.default.rx.notification(.UIKeyboardDidHide)).merge()
            .subscribeNext { [weak self] notification in
                guard let `self` = self else { return }
                self.searchBar.subviews.flatMap({$0.subviews}).forEach({ ($0 as? UIButton)?.isEnabled = true })
            }.disposed(by: rx.disposeBag)
    }

    private func fecthResult() {
        guard let `query` = query else { return }

        search(query: query, offset: offset, size: size, sortType: sortType, success: { [weak self] results in
            guard let `self` = self else { return }
            self.searchResults.append(contentsOf: results)
            self.endLoading()
            self.tableView.endFooterRefresh()

            self.offset += self.size
        }) { [weak self] error in
            self?.endLoading()
            self?.tableView.endFooterRefresh()
            HUD.showText(error)
        }
    }

    // MARK: State Handle

    override func hasContent() -> Bool {
        return isSearched ? searchResults.count.boolValue : true
    }

    override func loadData() {

    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {

    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {

    }

    public func search(query: String?, selectedScope: Int) {
        guard let `query` = query?.trimmed, query.isNotEmpty else { return }

        searchResults.removeAll()
        isSearched = true
        startLoading()

        let previousType = self.sortType
        self.query = query
        self.sortType = selectedScope == 0 ? .sumup : .created

        if previousType != sortType {
            offset = 0
            searchResults.removeAll()
        }

        fecthResult()
    }
}

extension TopicSearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicSearchResultCell.self)!
        cell.query = query
        cell.topic = searchResults[indexPath.row].topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = searchResults[indexPath.row].id else { return }
        let topicDetailVC = TopicDetailViewController(topicID: id)
//        presentingViewController?.navigationController?.pushViewController(topicDetailVC, animated: true)
        navigationController?.pushViewController(topicDetailVC, animated: true)
    }
}

extension TopicSearchResultViewController : UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
