import UIKit
import SnapKit
import ViewAnimator
import StatefulViewController

class HomeViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
//        view.estimatedRowHeight = 80
//        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()

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

    var topics: [TopicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupSubviews() {
        navigationItem.titleView = tabView
        
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }

            self.tableView.setContentOffset(CGPoint(x: -self.tableView.contentInset.left, y: -self.tableView.contentInset.top), animated: true)
            self.fetchTopic()
        }
        tableView.addSubview(refreshControl)

        startLoading()
        fetchIndexData()
        setupStateFul()
    }


    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setupRx() {

        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchTopic()
            }.disposed(by: rx.disposeBag)
    }

    func fetchIndexData() {

        index(success: { [weak self] nodes, topics in
            guard let `self` = self else { return }

            self.nodes = nodes
            self.topics = topics
            self.endLoading()
            
            }, failure: { [weak self] error in
                HUD.dismiss()
                HUD.showText(error)
                self?.endLoading()
                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.title = error
                }
        })
    }

    func fetchTopic() {
        let href = nodes[tabView.selectIndex].href
        topics(href: href, success: { [weak self] topic in
            self?.topics = topic
            self?.refreshControl.endRefreshing()
            }, failure: { [weak self] error in
                self?.refreshControl.endRefreshing()
                HUD.showText(error)

                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.title = error
                }
        })
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return topics[indexPath.row].cellHeight
    }
}

extension HomeViewController: StatefulViewController {

    func hasContent() -> Bool {
        return nodes.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        emptyView = EmptyView(frame: tableView.frame,
                              title: "加载失败")

        setupInitialViewState()
    }
}

