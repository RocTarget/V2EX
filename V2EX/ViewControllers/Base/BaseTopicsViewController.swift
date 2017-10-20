import UIKit
import StatefulViewController

class BaseTopicsViewController: BaseViewController, TopicService, StatefulViewController {

    internal lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.register(cellWithClass: TopicCell.self)
        self.view.addSubview(view)
        return view
    }()

    internal lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()

    var topics: [TopicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    public var href: String

    init(href: String) {
        self.href = href
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(href: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupSubviews() {
        registerForPreviewing(with: self, sourceView: tableView)

        tableView.addSubview(refreshControl)

        startLoading()
        setupStateFul()
        fetchData()
    }

    internal func fetchData() {
        fetchTopic()
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

    func fetchTopic() {

        topics(href: href, success: { [weak self] topic in
            self?.topics = topic
            self?.refreshControl.endRefreshing()
            self?.endLoading()
            }, failure: { [weak self] error in
                self?.refreshControl.endRefreshing()
                self?.endLoading()
                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.message = error
                }
        })
    }

    func hasContent() -> Bool {
        return topics.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            self?.startLoading()
            self?.fetchTopic()
        }
        emptyView = ev
        setupInitialViewState()
    }
    
}

extension BaseTopicsViewController: UITableViewDelegate, UITableViewDataSource {
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

extension BaseTopicsViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let topicID = topics[indexPath.row].topicId else { return nil }

        let viewController = TopicDetailViewController(topicID: topicID)
//        viewController.preferredContentSize = CGSize(width: view.width, height: view.height * 0.7)
        previewingContext.sourceRect = cell.frame
        return viewController
    }
}
