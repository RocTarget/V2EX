import Foundation
import UIKit
import StatefulViewController
import SafariServices

class TopicDetailViewController: BaseViewController, TopicService {
    
    private struct Metric {
        static let commentInputViewHeight: CGFloat = 55
    }
    
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
    
    private var dataSources: [CommentModel] = []
    
    private var comments: [CommentModel] = []
    
    private var commentText: String = ""
    
    private var isShowOnlyFloor: Bool = false
    
    init(topicID: String) {
        self.topicID = topicID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "moreNav"),
            style: .plain,
            action: { [weak self] in
                self?.moreHandle()
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
            $0.height.equalTo(Metric.commentInputViewHeight)
        }
    }
    
    override func setupRx() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchTopicDetail()
            }.disposed(by: rx.disposeBag)
    }
    
    private func tapHandle(_ type: TapType) {
        switch type {
        case .webpage(let url):
            let webView = SweetWebViewController(url: url)
            self.navigationController?.pushViewController(webView, animated: true)
        case .member(let member):
            let memberPageVC = MemberPageViewController(member: member)
            self.navigationController?.pushViewController(memberPageVC, animated: true)
        case .image(let src):
            log.info(src)
        case .node(let node):
            let nodeDetailVC = NodeDetailViewController(node: node)
            self.navigationController?.pushViewController(nodeDetailVC, animated: true)
        case .topic(let topicID):
            let topicDetailVC = TopicDetailViewController(topicID: topicID)
            self.navigationController?.pushViewController(topicDetailVC, animated: true)
            log.info()
        }
    }
    
    private func moreHandle() {
        let floorItem = isShowOnlyFloor ? ShareItem(icon: #imageLiteral(resourceName: "unfloor"), title: "查看所有", type: .floor) : ShareItem(icon: #imageLiteral(resourceName: "floor"), title: "只看楼主", type: .floor)
        let favoriteItem = (topic?.isFavorite ?? false) ? ShareItem(icon: #imageLiteral(resourceName: "favorite"), title: "取消收藏", type: .favorite) : ShareItem(icon: #imageLiteral(resourceName: "unfavorite"), title: "收藏", type: .favorite)
        let section1 = [
            floorItem,
            favoriteItem,
            ShareItem(icon: #imageLiteral(resourceName: "thank"), title: "感谢", type: .thank),
            ShareItem(icon: #imageLiteral(resourceName: "ignore"), title: "忽略", type: .ignore),
            ]
        
        
        let section2 = [
            ShareItem(icon: #imageLiteral(resourceName: "copy_link"), title: "复制链接", type: .copyLink),
            ShareItem(icon: #imageLiteral(resourceName: "safari"), title: "在 Safari 中打开", type: .safari),
            ShareItem(icon: #imageLiteral(resourceName: "share"), title: "分享", type: .share),
            //            ShareItem(icon: #imageLiteral(resourceName: "refresh_icon"), title: "刷新", type: .refresh),
        ]
        
        let sheetView = ShareSheetView(sections: [section1, section2], isScrollEnabled: false)
        sheetView.present()
        sheetView.shareSheetDidSelectedHandle = { [weak self] type in
            self?.shareSheetDidSelectedHandle(type)
        }
    }

    func shareSheetDidSelectedHandle(_ type: ShareItemType) {

        if type.needAuth, !AccountModel.isLogin{
            HUD.showText("请先登录")
            return
        }

        switch type {
        case .floor:
            if isShowOnlyFloor {
                dataSources = comments
            } else {
                let result = comments.filter { $0.member.username == topic?.member?.username }
                dataSources = result
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            isShowOnlyFloor = !isShowOnlyFloor
            return
        case .favorite:
            favoriteHandle()
        case .copyLink:
            UIPasteboard.general.string = API.topicDetail(topicID: topicID).defaultURLString
            HUD.showText("链接已复制")
        case .safari:
            guard let url = API.topicDetail(topicID: topicID).url else {
                HUD.showText("无法打开网页")
                return
            }
            UIApplication.shared.openURL(url)
        case .share:
            systemShare()
        default:
            break
        }
    }
    
    func systemShare() {
        
        guard let url = API.topicDetail(topicID: topicID).url,
            let title = topic?.title else { return }
        
        let controller = UIActivityViewController(
            activityItems: [url, title, headerView.userAvatar ?? #imageLiteral(resourceName: "logo")],
            applicationActivities: nil)
        
        controller.excludedActivityTypes = [
            .postToTwitter, .postToFacebook, .postToTencentWeibo, .postToWeibo,
            .postToFlickr, .postToVimeo, .message, .mail, .addToReadingList,
            .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll,
        ]
        
        if UIDevice.isiPad {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5, width: 10, height: 10)
        }
        present(controller, animated: true, completion: nil)
    }
    
    func favoriteHandle() {

        guard let `topic` = topic,
            let token = topic.token else {
                HUD.showText("操作失败")
                return
        }
        // 已收藏, 取消收藏
        if topic.isFavorite {
            unfavoriteTopic(topicID: topicID, token: token, success: { [weak self] in
                HUD.showText("取消收藏成功")
                self?.topic?.isFavorite = false
            }, failure: { error in
                HUD.showText(error)
            })
            return
        }
        
        // 没有收藏
        unfavoriteTopic(topicID: topicID, token: token, success: { [weak self] in
            HUD.showText("收藏成功")
            self?.topic?.isFavorite = true
        }) { error in
            HUD.showText(error)
        }
    }
    
    private func replyComment() {
        
        guard let `topic` = self.topic else {
            HUD.showText("回复失败")
            return
        }
        
        guard AccountModel.isLogin else {
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
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCommentCell.self)!
        let comment = dataSources[indexPath.row]
        cell.comment = comment
        cell.hostUsername = topic?.member?.username ?? ""
        cell.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = dataSources[indexPath.row]
        commentInputView.text = "@\(comment.member.username) "
        commentInputView.beFirstResponder()
    }
}

extension TopicDetailViewController {
    
    func fetchTopicDetail() {
        
        topicDetail(topicID: topicID, success: { [weak self] topic, comments in
            self?.topic = topic
            self?.dataSources = comments
            self?.comments = comments
            self?.refreshControl.endRefreshing()
            self?.endLoading()
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
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchTopicDetail()
        }
        emptyView = ev
        setupInitialViewState()
    }
}

