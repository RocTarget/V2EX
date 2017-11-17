import UIKit

class TopicSearchResultViewController: DataViewController, TopicService {

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
    
    private var offset = 0
    private var size = 20
    
    private var query: String?

    private var sortType: SearchSortType = .sumup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = [.bottom]
        
        status = .noSearchResult
        
        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
            }.disposed(by: rx.disposeBag)
    }
    
    override func setupSubviews() {
        startLoading()

        tableView.addFooterRefresh { [weak self] in
            self?.fecthResult()
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
        return searchResults.count.boolValue
    }

    override func loadData() {

    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {

    }
    
    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        
    }

    public func search(query: String?, selectedScope: Int) {
        guard let `query` = query?.trimmed, query.isNotEmpty else { return }

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
        presentingViewController?.navigationController?.pushViewController(topicDetailVC, animated: true)
    }
}
