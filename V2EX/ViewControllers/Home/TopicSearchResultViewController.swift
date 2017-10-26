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
        tableView.backgroundColor = Theme.Color.bgColor
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = [.bottom]

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
        }
    }
    
    override func setupSubviews() {
        startLoading()
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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

    public func search(query: String?, selectedScope: Int) {
        guard let `query` = query?.trimmed, query.isNotEmpty else { return }
        
        self.query = query
        let sortType: SearchSortType = selectedScope == 0 ? .sumup : .created
        search(query: query, offset: offset, size: size, sortType: sortType, success: { [weak self] results in
            self?.searchResults = results
            self?.endLoading()
        }) { [weak self] error in
            self?.endLoading()
            HUD.showText(error)
        }
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
