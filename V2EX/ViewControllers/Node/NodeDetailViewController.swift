import UIKit

class NodeDetailViewController: BaseViewController, NodeService {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 80
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCell.self)
        self.view.addSubview(view)
        return view
    }()
    
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()
    
    public var node: NodeModel
    
    var topics: [TopicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(node: NodeModel) {
        self.node = node
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = node.name
        
        tableView.addSubview(refreshControl)
        
        fetchNodeDetail()
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchNodeDetail()
            }.disposed(by: rx.disposeBag)
    }
    
    func fetchNodeDetail() {
        
        HUD.show()
        nodeDetail(
            node: node,
            success: { [weak self] node, topics in
                self?.node = node
                self?.topics = topics
                HUD.dismiss()
                self?.refreshControl.endRefreshing()
        }) { [weak self] error in
            self?.refreshControl.endRefreshing()
            HUD.dismiss()
            HUD.showText(error)
        }
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NodeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
        let topic = topics[indexPath.row]
        cell.topic = topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicDetailVC = TopicDetailViewController()
        topicDetailVC.topic = topics[indexPath.row]
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }
    
}
