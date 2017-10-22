import UIKit
import StatefulViewController

class BaseTopicsViewController: BaseViewController, TopicService, StatefulViewController {

    internal lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
//        view.separatorStyle = .none
        view.register(cellWithClass: TopicCell.self)
        view.keyboardDismissMode = .onDrag
        view.hideEmptyCells()
        self.view.addSubview(view)
        return view
    }()

    internal lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.backgroundColor = .clear
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

        
        setupStateFul()
        fetchData()
    }

    internal func fetchData() {
        startLoading()
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

    
    func tapHandle(_ type: TapType) {
        switch type {
        case .member(let member):
            let memberPageVC = MemberPageViewController(member: member)
            navigationController?.pushViewController(memberPageVC, animated: true)
            log.info(member)
        case .node(let node):
            let nodeDetailVC = NodeDetailViewController(node: node)
            navigationController?.pushViewController(nodeDetailVC, animated: true)
        default:
            break
        }
    }
    
    
    
    func hasContent() -> Bool {
        return topics.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchData()
        }
        emptyView = ev
        setupInitialViewState()
    }
    
}

extension BaseTopicsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
        let topic = topics[indexPath.section]
        cell.topic = topic
        cell.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        let topic = topics[indexPath.section]
        guard let topicId = topic.topicID else {
            HUD.showText("操作失败，无法解析主题 ID")
            return
        }
        let topicDetailVC = TopicDetailViewController(topicID: topicId)
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return topics[indexPath.section].cellHeight
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.01
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView()
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView()
//    }
}

extension BaseTopicsViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let topicID = topics[indexPath.row].topicID else { return nil }

        let viewController = TopicDetailViewController(topicID: topicID)
        previewingContext.sourceRect = cell.frame
        return viewController
    }
}
