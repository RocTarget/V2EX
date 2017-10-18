import UIKit
import StatefulViewController

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
    
    public var node: NodeModel {
        didSet {
            title = node.name
        }
    }
    
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

        tableView.addSubview(refreshControl)
        
        fetchNodeDetail()
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchNodeDetail()
            }.disposed(by: rx.disposeBag)
    }

    override func setupSubviews() {

        startLoading()
        fetchNodeDetail()
        setupStateFul()
    }
    
    func fetchNodeDetail() {

        nodeDetail(
            node: node,
            success: { [weak self] node, topics in
                self?.node = node
                self?.topics = topics
                self?.refreshControl.endRefreshing()
                self?.endLoading()
        }) { [weak self] error in
            self?.refreshControl.endRefreshing()

            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.title = error
            }
            self?.endLoading()
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
        let topic = topics[indexPath.row]
        guard let topicId = topic.topicId else {
            HUD.showText("操作失败，无法解析主题 ID")
            return
        }
        let topicDetailVC = TopicDetailViewController(topicID: topicId)
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }
    
}

extension NodeDetailViewController: StatefulViewController {

    func hasContent() -> Bool {
        return topics.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        emptyView = EmptyView(frame: tableView.frame,
                              title: "加载失败")

        setupInitialViewState()
    }
}

