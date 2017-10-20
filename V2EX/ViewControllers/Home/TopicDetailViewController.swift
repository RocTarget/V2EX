import Foundation
import UIKit
import StatefulViewController

class TopicDetailViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.rowHeight = UITableViewAutomaticDimension
        view.estimatedRowHeight = 80
        view.backgroundColor = .clear
        view.keyboardDismissMode = .onDrag
        view.register(cellWithClass: TopicCommentCell.self)
        self.view.addSubview(view)
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()

    private lazy var headerView: TopicDetailHeaderView = {
        let view = TopicDetailHeaderView()
        view.isHidden = true
        return view
    }()

    private lazy var commentInputView: CommentInputView = {
        let view = CommentInputView(frame: .zero)
        self.view.addSubview(view)
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
    
    var commentText: String = ""

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }

    override func setupSubviews() {

        tableView.addSubview(refreshControl)
        tableView.tableHeaderView = headerView

        headerView.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }

        commentInputView.sendHandle = { [weak self] in
            self?.replyComment()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "moreNav"), style: .plain, action: {
            log.info("plain")
        })

        title = "加载中..."
        startLoading()
        fetchTopicDetail()
        setupStateFul()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(commentInputView.snp.top)
        }

        commentInputView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(55)
        }
    }

    override func setupRx() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchTopicDetail()
            }.disposed(by: rx.disposeBag)
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

    func replyComment() {

        guard let `topic` = self.topic else {
            HUD.showText("回复失败")
            return
        }

        guard UserModel.isLogin else {
            HUD.showText("请先登录", completionBlock: {
                presentLoginVC()
            })
            return
        }

        guard commentInputView.text.trimmed.isNotEmpty else {
            HUD.showText("回复失败，您还没有输入任何内容", completionBlock: { [weak self] in
                self?.commentInputView.beFirstResponder()
            })
            return
        }

        guard let once = topic.once else {
            HUD.showText("无法获取 once，请尝试重新登录", completionBlock: {
                presentLoginVC()
            })
            return
        }

        commentText = commentInputView.text
        commentInputView.text = ""
        
        HUD.show()
        comment(
            once: once,
            topicID: topicID,
            content: commentText, success: { [weak self] in
                self?.fetchTopicDetail()
                HUD.showText("回复成功")
                HUD.dismiss()
        }) { [weak self] error in
            guard let `self` = self else { return }
            HUD.dismiss()
            HUD.showText(error)
            self.commentInputView.text = self.commentText
            self.commentInputView.beFirstResponder()
        }
    }
}

extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCommentCell.self)!
        let comment = comments[indexPath.row]
        cell.comment = comment
        cell.hostUsername = topic?.user?.username ?? ""
        cell.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = comments[indexPath.row]
        commentInputView.text = "@\(comment.user.username) "
        commentInputView.beFirstResponder()
    }
}

extension TopicDetailViewController {

    func fetchTopicDetail() {

        topicDetail(topicID: topicID, success: { [weak self] topic, comments in
            self?.topic = topic
            self?.comments = comments
            self?.refreshControl.endRefreshing()

            }, failure: { [weak self] error in

                HUD.showText(error)

                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.message = error
                }
                self?.endLoading()
                self?.refreshControl.endRefreshing()
        })

        headerView.webLoadComplete = { [weak self] in
            self?.endLoading()
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
        emptyView = EmptyView(frame: tableView.frame)
        setupInitialViewState()
    }
}

