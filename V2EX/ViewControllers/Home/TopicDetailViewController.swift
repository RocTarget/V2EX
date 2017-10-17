import Foundation
import UIKit
import StatefulViewController

class TopicDetailViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.estimatedRowHeight = 80
        view.backgroundColor = .clear
        view.rowHeight = UITableViewAutomaticDimension
        view.register(cellWithClass: TopicCommentCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var headerView: TopicDetailHeaderView = {
        let view = TopicDetailHeaderView()
        view.isHidden = true
        return view
    }()

    var topic: TopicModel? {
        didSet {
            guard let topic = topic else { return }
            self.title = topic.title
            headerView.topic = topic
        }
    }

    var topicID: String

    var comments: [CommentModel] = []

    init(topicID: String) {
        self.topicID = topicID

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchTopicDetail()
    }

    override func setupSubviews() {
        tableView.tableHeaderView = headerView

        headerView.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }

        title = "加载中..."
        startLoading()
        fetchTopicDetail()
        setupStateFul()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func tapHandle(_ type: TapType) {
        switch type {
        case .webpage(let url):
            let webView = SweetWebViewController(url: url)
            self.navigationController?.pushViewController(webView, animated: true)
        case .user(let user):
            let memberPageVC = MemberPageViewController()
            self.navigationController?.pushViewController(memberPageVC, animated: true)
            log.info(user)
        case .image(let src):
            log.info(src)
            break
        case .node(let node):
            let nodeDetailVC = NodeDetailViewController(node: node)
            self.navigationController?.pushViewController(nodeDetailVC, animated: true)
        case .topic(let topicID):
            let topicDetailVC = TopicDetailViewController(topicID: topicID)
            self.navigationController?.pushViewController(topicDetailVC, animated: true)
            log.info()
        }

    }
}

extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCommentCell.self)!
        cell.comment = comments[indexPath.row]
        return cell
    }
}

extension TopicDetailViewController {
    func fetchTopicDetail() {

        topicDetail(topicID: topicID, success: { [weak self] topic, comments in
            self?.topic = topic
            self?.comments = comments
            self?.endLoading()
            }, failure: { [weak self] error in

                HUD.showText(error)

                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.title = error
                }
                self?.endLoading()
        })

        headerView.webLoadComplete = { [weak self] in
            self?.headerView.isHidden = false
            self?.tableView.reloadData()
        }
    }
}


extension TopicDetailViewController: StatefulViewController {

    func hasContent() -> Bool {
        return topic != nil
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        emptyView = EmptyView(frame: tableView.frame,
                              title: "加载失败")

        setupInitialViewState()
    }
}
