import UIKit
import StatefulViewController

class NodeSearchResultViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.hideEmptyCells()
        tableView.backgroundColor = Theme.Color.bgColor
        self.view.addSubview(tableView)
        return tableView
    }()
    
    public var originData: [NodeModel]?
    
    private var searchResults: [NodeModel] = [] {
        didSet {
            tableView.reloadData()
            endLoading()
        }
    }
    
    private var query: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupSubviews() {
        setupStateFul()
        startLoading()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
        cell?.textLabel?.text = searchResults[indexPath.row].name
        if let `query` = query {
            cell?.textLabel?.makeSubstringColor(query, color: UIColor.hex(0xD33F3F))
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = searchResults[indexPath.row]
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
        searchResults = originData.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
}

extension NodeSearchResultViewController: StatefulViewController {
    
    func hasContent() -> Bool {
        return searchResults.count.boolValue
    }
    
    func setupStateFul() {
        let ev = EmptyView(frame: tableView.frame)
        ev.type = .empty
        emptyView = ev
        setupInitialViewState()
    }
}

