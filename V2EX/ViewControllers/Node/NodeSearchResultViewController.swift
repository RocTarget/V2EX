import UIKit

class NodeSearchResultViewController: DataViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.hideEmptyCells()
        tableView.backgroundColor = Theme.Color.bgColor
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.view.addSubview(tableView)
        return tableView
    }()
    
    public var originData: [NodeModel]?

    public var didSelectedNodeHandle:((NodeModel) -> Void)?

    private var query: String?

    private var searchResults: [NodeModel] = [] {
        didSet {
            tableView.reloadData()
            endLoading()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []
        automaticallyAdjustsScrollViewInsets = false
        status = .noSearchResult
    }
    
    override func setupSubviews() {
        status = .empty
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
}


extension NodeSearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NodesCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "NodesCell")
            cell?.separatorInset = .zero
        }
        cell?.textLabel?.text = searchResults[indexPath.row].title
        if let `query` = query {
            cell?.textLabel?.makeSubstringColor(query, color: UIColor.hex(0xD33F3F))
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = searchResults[indexPath.row]

        if let callback = didSelectedNodeHandle {
            dismiss(animated: true, completion: {
                callback(node)
            })
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)
        let nodeDetailVC = NodeDetailViewController(node: node)
        presentingViewController?.navigationController?.pushViewController(nodeDetailVC, animated: true)
    }
}

extension NodeSearchResultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.trimmed,
            query.isNotEmpty,
            let `originData` = originData else {
                return
        }
        self.query = query
        searchResults = originData.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
