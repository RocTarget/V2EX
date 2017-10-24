import Foundation
import UIKit
import SafariServices

class TopicDetailViewController: DataViewController, TopicService {
    
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
    
    private var topic: TopicModel? {
        didSet {
            guard let topic = topic else { return }
            self.title = topic.title
            headerView.topic = topic
        }
    }
    
    private var selectComment: CommentModel? {
        guard let selectIndexPath = tableView.indexPathForSelectedRow else {
            return nil
        }
        return comments[selectIndexPath.row]
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !isFirstResponder {
            if action == #selector(copyCommentAction) ||
                action == #selector(replyCommentAction) ||
                action == #selector(thankCommentAction) ||
                action == #selector(viewDialogAction) {
                    return false
            }

        }
        return super.canPerformAction(action, withSender: sender)
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
        
        commentInputView.atUserHandle = { [weak self] in
            guard let `comments` = self?.comments else { return }
            guard let `self` = self else { return }
            
            // 解层
            let members = comments.flatMap { $0.member }
            let memberSet = Set<MemberModel>(members)
            let uniqueMembers = Array(memberSet).filter { $0.username != AccountModel.current?.username }
            let memberListVC = MemberListViewController(members: uniqueMembers )
            let nav = NavigationViewController(rootViewController: memberListVC)
            self.present(nav, animated: true, completion: nil)
            
            memberListVC.callback = { members in
                self.commentInputView.beFirstResponder()
                
                guard members.count.boolValue else { return }
                
                let ats = members
                    .filter{ !self.commentInputView.text.contains($0.username) }
                    .map { "@" + $0.username + " " }
                    .joined()
                self.commentInputView.text.append(ats)
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "moreNav"),
            style: .plain,
            action: { [weak self] in
                self?.moreHandle()
        })
        
        title = "加载中..."
        //        fetchTopicDetail()
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.bottom.equalTo(commentInputView.snp.top)
        }
        
        commentInputView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                $0.height.equalTo(Metric.commentInputViewHeight + view.safeAreaInsets.bottom)
            } else {
                $0.height.equalTo(Metric.commentInputViewHeight)
            }
        }
    }
    
    override func setupRx() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchTopicDetail()
            }.disposed(by: rx.disposeBag)
    }
    
    // MARK: States Handle
    
    override func hasContent() -> Bool {
        return topic != nil
    }
    
    override func loadData() {
        fetchTopicDetail()
    }
    
    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchTopicDetail()
    }
    
    
    private func tapHandle(_ type: TapType) {
        switch type {
        case .webpage(let url):
            let webView = SweetWebViewController(url: url)
            self.navigationController?.pushViewController(webView, animated: true)
        case .member(let member):
            let memberPageVC = MemberPageViewController(member: member)
            self.navigationController?.pushViewController(memberPageVC, animated: true)
        case .memberAvatarLongPress(let member):
            avatarLongPressHandle(member.username)
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
    
    /// 点击更多处理
    private func moreHandle() {
        
        /// 切换 是否显示楼主
        let floorItem = isShowOnlyFloor ?
            ShareItem(icon: #imageLiteral(resourceName: "unfloor"), title: "查看所有", type: .floor) :
            ShareItem(icon: #imageLiteral(resourceName: "floor"), title: "只看楼主", type: .floor)
        let favoriteItem = (topic?.isFavorite ?? false) ?
            ShareItem(icon: #imageLiteral(resourceName: "favorite"), title: "取消收藏", type: .favorite) :
            ShareItem(icon: #imageLiteral(resourceName: "unfavorite"), title: "收藏", type: .favorite)
        
        var section1 = [floorItem, favoriteItem]
        
        // 如果已经登录 并且 是当前登录用户发表的主题, 则隐藏 感谢和忽略
        let username = AccountModel.current?.username ?? ""
        if username != topic?.member?.username {
            let thankItem = (topic?.isThank ?? false) ?
                ShareItem(icon: #imageLiteral(resourceName: "thank"), title: "已感谢", type: .thank) :
                ShareItem(icon: #imageLiteral(resourceName: "alreadyThank"), title: "感谢", type: .thank)
            
            section1.append(thankItem)
            section1.append(ShareItem(icon: #imageLiteral(resourceName: "ignore"), title: "忽略", type: .ignore))
        }
        
        let section2 = [
            ShareItem(icon: #imageLiteral(resourceName: "copy_link"), title: "复制链接", type: .copyLink),
            ShareItem(icon: #imageLiteral(resourceName: "safari"), title: "在 Safari 中打开", type: .safari),
            ShareItem(icon: #imageLiteral(resourceName: "share"), title: "分享", type: .share)
        ]
        
        let sheetView = ShareSheetView(sections: [section1, section2], isScrollEnabled: false)
        sheetView.present()
        
        sheetView.shareSheetDidSelectedHandle = { [weak self] type in
            self?.shareSheetDidSelectedHandle(type)
        }
    }
    
    func shareSheetDidSelectedHandle(_ type: ShareItemType) {
        
        // 需要授权的操作
        if type.needAuth, !AccountModel.isLogin{
            HUD.showText("请先登录")
            return
        }
        
        switch type {
        case .floor:
            showOnlyFloorHandle()
        case .favorite:
            favoriteHandle()
        case .thank:
            thankTopicHandle()
        case .ignore:
            ignoreTopicHandle()
        case .copyLink:
            UIPasteboard.general.string = API.topicDetail(topicID: topicID).defaultURLString
            HUD.showText("链接已复制")
        case .safari:
            openSafariHandle()
        case .share:
            systemShare()
        default:
            break
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
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
        log.info(comment.isThank, comment.content)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // TODO: 换成点击弹出 SheetView (或其他 UI 展示), 长按头像添加 @, 可以添加多个
        // Sheet option:
        // 1, 回复
        // 2, 感谢
        // 3, 查看对话
        // 4, ...
        let comment = dataSources[indexPath.row]
        
        if commentInputView.isFirstResponder { return }
        
        let menuVC = UIMenuController.shared
        let cell = tableView.cellForRow(at: indexPath)!
        var targetRectangle = cell.frame
        targetRectangle.origin.y = targetRectangle.height * 0.4
        targetRectangle.size.height = 1
        
        let replyItem = UIMenuItem(title: "回复", action: #selector(replyCommentAction))
        let thankItem = UIMenuItem(title: "感谢", action: #selector(thankCommentAction))
        let copyItem = UIMenuItem(title: "复制", action: #selector(copyCommentAction))
        let viewDialogItem = UIMenuItem(title: "查看对话", action: #selector(viewDialogAction))
        menuVC.setTargetRect(targetRectangle, in: cell)
        menuVC.menuItems = [replyItem, copyItem, viewDialogItem]
        if !comment.isThank {
            menuVC.menuItems?.insert(thankItem, at: 1)
        }
        menuVC.setMenuVisible(true, animated: true)
        
    }
}

// MARK: - 点击回复的相关操作
extension TopicDetailViewController {
    
    @objc func replyCommentAction() {
        guard let username = selectComment?.member.username else { return }
        commentInputView.text = "@\(username) "
        commentInputView.beFirstResponder()
    }
    
    // TODO: 未调试
    @objc func thankCommentAction() {
        guard let replyID = selectComment?.id,
            let token = topic?.token else { return }
        thankReply(replyID: replyID, token: token, success: { [weak self] in
            guard let `self` = self,
                let selectRow = self.tableView.indexPathForSelectedRow?.row else { return }
            HUD.showText("已成功发送感谢")
            self.comments[selectRow].isThank = true
        }) { error in
            HUD.showText(error)
        }
    }
    
    @objc func copyCommentAction() {
        /// TODO: 直接取 content 是 HTML, 应该只要内容
        guard let content = selectComment?.content else { return }
        UIPasteboard.general.string = content
    }
    
    @objc func viewDialogAction() {
        log.info("查看对话: ", selectComment?.member.username)
    }
}


// MARK: - Request
extension TopicDetailViewController {
    
    /// 获取主题详情
    func fetchTopicDetail() {
        startLoading()
        
        topicDetail(topicID: topicID, success: { [weak self] topic, comments in
            self?.topic = topic
            self?.dataSources = comments
            self?.comments = comments
            self?.refreshControl.endRefreshing()
            self?.endLoading()
            }, failure: { [weak self] error in
                if let `errorView` = self?.errorView as? ErrorView {
                    errorView.message = error
                }
                self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
                self?.refreshControl.endRefreshing()
        })
        
        headerView.webLoadComplete = { [weak self] in
            self?.endLoading()
            self?.headerView.isHidden = false
            self?.tableView.reloadData()
        }
    }
    
    /// 回复评论
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
    
    /// 收藏、取消收藏请求
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
        favoriteTopic(topicID: topicID, token: token, success: { [weak self] in
            HUD.showText("收藏成功")
            self?.topic?.isFavorite = true
        }) { error in
            HUD.showText(error)
        }
    }
    
    /// 感谢主题请求
    func thankTopicHandle() {
        
        guard let `topic` = topic else {
            HUD.showText("操作失败")
            return
        }
        
        // 已感谢
        guard !topic.isThank else {
            HUD.showText("主题已感谢，无法重复提交")
            return
        }
        
        guard let token = topic.token else {
            HUD.showText("操作失败")
            return
        }
        
        // TODO: 感谢发送成功之后 会提示数据解析失败, 这里需要测试
        thankTopic(topicID: topicID, token: token, success: { [weak self] in
            HUD.showText("感谢已发送")
            self?.topic?.isThank = true
        }) { error in
            HUD.showText(error)
        }
    }
    
    /// 感谢回复请求
    // TODO: 未调试, UI还没做
    func thankReplyHandle(replyID: String) {
        
        guard let `topic` = topic,
            let token = topic.token else {
                HUD.showText("操作失败")
                return
        }
        
        thankReply(replyID: replyID, token: token, success: {
            HUD.showText("感谢已发送")
            // TODO: 修改状态，解析评论时需要解析是否已经感谢
            //            comment.isThank = true
        }) { error in
            HUD.showText(error)
        }
    }
    
    /// 忽略主体请求
    func ignoreTopicHandle() {
        guard let `topic` = topic,
            let once = topic.once else {
                HUD.showText("操作失败")
                return
        }
        
        ignoreTopic(topicID: topicID, once: once, success: { [weak self] in
            // 需要 pop 掉该控制器? YES
            // 需要刷新主题列表？ NO
            HUD.showText("已成功忽略该主题", completionBlock: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
        }) { error in
            HUD.showText(error)
        }
    }
}

// MARK: - Action Handle
extension TopicDetailViewController {
    
    func avatarLongPressHandle(_ username: String) {
        let atStr = "@\(username)"
        commentInputView.beFirstResponder()
        
        if commentInputView.text.contains(atStr) { return }
        commentInputView.text.append(" \(atStr) ")
    }
    
    /// 打开系统分享
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
    
    /// 是否只看楼主
    func showOnlyFloorHandle() {
        if isShowOnlyFloor {
            dataSources = comments
        } else {
            let result = comments.filter { $0.member.username == topic?.member?.username }
            dataSources = result
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        isShowOnlyFloor = !isShowOnlyFloor
    }
    
    /// 从系统 Safari 浏览器中打开
    func openSafariHandle() {
        guard let url = API.topicDetail(topicID: topicID).url,
            UIApplication.shared.canOpenURL(url) else {
                HUD.showText("无法打开网页")
                return
        }
        UIApplication.shared.openURL(url)
    }
}
