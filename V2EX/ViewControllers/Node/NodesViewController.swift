import UIKit
import RxSwift
import RxCocoa

class NodesViewController: DataViewController, NodeService {
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["节点导航", "全部节点"])
        view.tintColor = Theme.Color.globalColor
        view.selectedSegmentIndex = 0
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        layout.minimumInteritemSpacing = 15
        layout.headerReferenceSize = CGSize(width: self.view.width, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.dataSource = self
        view.delegate = self
        view.register(NodeCell.self, forCellWithReuseIdentifier: NodeCell.description())
        view.register(NodeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NodeHeaderView.description())
        self.view.addSubview(view)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.alpha = 0
        view.sectionIndexColor = Theme.Color.globalColor
        view.sectionIndexBackgroundColor = .clear
        view.sectionIndexTrackingBackgroundColor = Theme.Color.bgColor
        view.hideEmptyCells()
        view.backgroundColor = Theme.Color.bgColor
        view.tableHeaderView = searchController.searchBar
        self.view.addSubview(view)
        return view
    }()
    
    private lazy var footerLabel: UILabel = {
        let footerLabel = UILabel()
        let nodeTotalCount = groups.flatMap { $0.nodes.count }.reduce(0, +)
        footerLabel.text = "\(nodeTotalCount) 个节点"
        footerLabel.sizeToFit()
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        footerLabel.height = 44
        return footerLabel
    }()
    
    private lazy var searchResultVC: NodeSearchResultViewController = {
        let view = NodeSearchResultViewController()
        return view
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchResultVC)
        searchController.searchBar.placeholder = "搜索节点"
        searchController.searchBar.tintColor = Theme.Color.globalColor
        searchController.searchBar.barTintColor = Theme.Color.bgColor
        searchController.searchResultsUpdater = searchResultVC
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
    
    private struct ReuseIdentifier {
        static let NodeCell = "NodeCell"
    }
    
    private var nodeCategorys: [NodeCategoryModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var groups: [NodeCategoryModel] = [] {
        didSet {
            tableView.reloadData()
            tableView.tableFooterView = footerLabel
            searchResultVC.originData = groups.flatMap { $0.nodes }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "节点导航"
        definesPresentationContext = true
        
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.height)
    }
    
    override func setupSubviews() {
        
        navigationItem.titleView = segmentedControl
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(self.navigationController?.navigationBar.bottom ?? 200)
        }
    }
    
    override func setupRx() {
        segmentedControl.rx
            .selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                self?.errorView?.isHidden = true
                self?.emptyView?.isHidden = true
                if index == 0 {
                    self?.collectionView.fadeIn()
                    self?.tableView.fadeOut()
                    self?.fetchNodeNav()
                } else {
                    self?.collectionView.fadeOut()
                    self?.tableView.fadeIn()
                    self?.fetchAllNode()
                }

            }).disposed(by: rx.disposeBag)
    }

    // MARK: State Handle

    override func loadData() {
        fetchNodeNav()
    }

    override func hasContent() -> Bool {
        return segmentedControl.selectedSegmentIndex == 0 ? nodeCategorys.count.boolValue : groups.count.boolValue
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        segmentedControl.selectedSegmentIndex == 0 ? fetchNodeNav() : fetchAllNode()
    }

    func fetchNodeNav() {
        if nodeCategorys.count.boolValue { return }
        
        startLoading()
        
        nodeNavigation(success: { [weak self] cates in
            self?.nodeCategorys = cates
            self?.endLoading()

            self?.errorView?.isHidden = false
            self?.emptyView?.isHidden = false
        }) { [weak self] error in
            if let `errorView` = self?.errorView as? ErrorView {
                errorView.message = error
            }
            self?.errorView?.isHidden = false
            self?.emptyView?.isHidden = false
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
        }
    }
    
    func fetchAllNode() {
        if groups.count.boolValue { return }
        
        startLoading()
        
        nodes(success: { [weak self] groups in
            self?.groups = groups
            self?.endLoading()
            self?.errorView?.isHidden = false
            self?.emptyView?.isHidden = false
        }) { [weak self] error in
            if let `errorView` = self?.errorView as? ErrorView {
                errorView.message = error
            }
            self?.errorView?.isHidden = false
            self?.emptyView?.isHidden = false
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension NodesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nodeCategorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodeCategorys[section].nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NodeCell.description(), for: indexPath) as! NodeCell
        cell.node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NodeHeaderView.description(), for: indexPath) as! NodeHeaderView
        headerView.title = nodeCategorys[indexPath.section].name
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        let nodeDetailVC = NodeDetailViewController(node: node)
        navigationController?.pushViewController(nodeDetailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NodesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        let w = node.name.toWidth(fontSize: 20)
        return CGSize(width: w, height: 30)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension NodesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.NodeCell)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: ReuseIdentifier.NodeCell)
        }
        cell?.textLabel?.text = groups[indexPath.section].nodes[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].name
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let headers = groups.map { $0.name }
//        headers.insert(UITableViewIndexSearch, at: 0)
        return headers
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Theme.Color.bgColor
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let node = groups[indexPath.section].nodes[indexPath.row]
        let nodeDetailVC = NodeDetailViewController(node: node)
        navigationController?.pushViewController(nodeDetailVC, animated: true)
    }
}
