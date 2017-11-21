import Foundation
import UIKit
import SafariServices
import SnapKit
import RxSwift
import RxCocoa
import MobileCoreServices

class TopicDetailViewController: DataViewController, TopicService {

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

    private lazy var imagePicker: UIImagePickerController = {
        let view = UIImagePickerController()
        view.mediaTypes = [kUTTypeImage as String]
        view.sourceType = .photoLibrary
        view.delegate = self
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
            title = topic.title
            headerView.topic = topic
        }
    }

    private var selectComment: CommentModel? {
        guard let selectIndexPath = tableView.indexPathForSelectedRow else {
            return nil
        }
        return dataSources[selectIndexPath.row]
    }

    public var topicID: String

    private var dataSources: [CommentModel] = []
    
    // 原始数据
    private var comments: [CommentModel] = []

    private var commentText: String = ""
    private var isShowOnlyFloor: Bool = false

    private var page = 1, maxPage = 1

    private var inputViewBottomConstranit: Constraint?
    private var inputViewHeightConstraint: Constraint?


    init(topicID: String) {
        self.topicID = topicID

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 如果当前 textView 是第一响应者，则忽略自定义的 MenuItemAction， 不在 Menu视图上显示自定义的 item
        if !isFirstResponder, [#selector(copyCommentAction),
                               #selector(replyCommentAction),
                               #selector(thankCommentAction),
                               #selector(viewDialogAction),
                               #selector(atMemberAction)].contains(action) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBarHiddn(false)
    }

    override func setupSubviews() {

        tableView.tableHeaderView = headerView

        headerView.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }

        headerView.webLoadComplete = { [weak self] in
            self?.endLoading()
            self?.headerView.isHidden = false
            self?.tableView.reloadData()
            self?.setupRefresh()
        }

        commentInputView.sendHandle = { [weak self] in
            self?.replyComment()
        }

        commentInputView.uploadPictureHandle = { [weak self] in
            guard let `self` = self else { return }
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        commentInputView.atUserHandle = { [weak self] in
            guard let `self` = self,
                self.comments.count.boolValue else { return }
            self.atMembers()
        }

        commentInputView.updateHeightHandle = { [weak self] height in
            self?.inputViewHeightConstraint?.update(offset: height)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "moreNav"),
            style: .plain,
            action: { [weak self] in
                self?.moreHandle()
        })

//        NotificationCenter.default.rx
//            .notification(Notification.Name.V2.HighlightTextClickName)
//            .subscribeNext { [weak self] noti in
//                guard let urlString = noti.object as? String,
//                    let url = URL(string: urlString) else { return }
//                self?.interactHook(url)
//            }.disposed(by: rx.disposeBag)

        title = "加载中..."
    }

    func setupRefresh() {

        tableView.addHeaderRefresh { [weak self] in
            self?.fetchTopicDetail()
        }

        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreComment()
        }
    }


    func interactHook(_ URL: URL) {
        let link = URL.absoluteString
        if URL.path.contains("/member/") {
            let href = URL.path
            let name = href.lastPathComponent
            let member = MemberModel(username: name, url: href, avatar: "")
            tapHandle(.member(member))
        } else if URL.path.contains("/t/") {
            let topicID = URL.path.lastPathComponent
            tapHandle(.topic(topicID))
        } else if URL.path.contains("/go/") {
            tapHandle(.node(NodeModel(title: "", href: URL.path)))
        } else if link.hasPrefix("https://") || link.hasPrefix("http://"){
            tapHandle(.webpage(URL))
        }
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        var inputViewHeight = KcommentInputViewHeight
        if #available(iOS 11.0, *) {
            inputViewHeight = KcommentInputViewHeight + view.safeAreaInsets.bottom
        }

        tableView.contentInset = UIEdgeInsetsMake(tableView.contentInset.top, tableView.contentInset.left, inputViewHeight, tableView.contentInset.right)

        commentInputView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            self.inputViewBottomConstranit = $0.bottom.equalToSuperview().constraint
            self.inputViewHeightConstraint = $0.height.equalTo(inputViewHeight).constraint
        }
    }

    // MARK: States Handle

    override func hasContent() -> Bool {
        return topic != nil
    }

    override func loadData() {
        fetchTopicDetail()

        keyboardControl()
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchTopicDetail()
    }

    private func keyboardControl() {

        Observable.of(NotificationCenter.default.rx.notification(.UIKeyboardWillShow),
                      NotificationCenter.default.rx.notification(.UIKeyboardWillHide),
                      NotificationCenter.default.rx.notification(.UIKeyboardDidShow),
                      NotificationCenter.default.rx.notification(.UIKeyboardDidHide)).merge()
            .subscribeNext { [weak self] notification in
                guard let `self` = self else { return }
                guard var userInfo = notification.userInfo,
                    let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                let convertedFrame = self.view.convert(keyboardRect, from: nil)
                let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
                self.inputViewBottomConstranit?.update(offset: -heightOffset)

                UIView.animate(withDuration: duration ?? 0.25) {
                    self.view.layoutIfNeeded()
                }
                //                self?.keyboardControl(notification)
            }.disposed(by: rx.disposeBag)
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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // 强制结束 HeaderView 中 WebView 的第一响应者， 不然无法显示 MenuView
        if !commentInputView.textView.isFirstResponder {
            view.endEditing(true)
        }

        // 如果当前控制器不是第一响应者不显示 MenuView
        guard isFirstResponder else { return }

        let comment = dataSources[indexPath.row]
        let menuVC = UIMenuController.shared
        let cell = tableView.cellForRow(at: indexPath)!
        var targetRectangle = cell.frame
        targetRectangle.origin.y = targetRectangle.height * 0.4
        targetRectangle.size.height = 1

        let replyItem = UIMenuItem(title: "回复", action: #selector(replyCommentAction))
        let atUserItem = UIMenuItem(title: "@TA", action: #selector(atMemberAction))
        let copyItem = UIMenuItem(title: "复制", action: #selector(copyCommentAction))
        let thankItem = UIMenuItem(title: "感谢", action: #selector(thankCommentAction))
        let viewDialogItem = UIMenuItem(title: "查看对话", action: #selector(viewDialogAction))
        menuVC.setTargetRect(targetRectangle, in: cell)
        menuVC.menuItems = [replyItem, copyItem, atUserItem, viewDialogItem]
        // 已经感谢 或 主题主是当前登录用户， 则不显示， 否则插入
        if !comment.isThank, topic?.member?.username != AccountModel.current?.username {
            menuVC.menuItems?.insert(thankItem, at: 1)
        }
        menuVC.setMenuVisible(true, animated: true)

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < (navigationController?.navigationBar.height ?? 64) { return }

        //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if (velocity < -5) {
            //向上拖动，隐藏导航栏
            setTabBarHiddn(true)
        }else if (velocity > 5) {
            //向下拖动，显示导航栏
            setTabBarHiddn(false)
        }else if (velocity == 0) {
            //停止拖拽
        }
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        setTabBarHiddn(false)
        return true
    }

    private func setTabBarHiddn(_ hidden: Bool) {
        //        commentInputView.layoutIfNeeded()
//        guard let navHeight = navigationController?.navigationBar.height else { return }

        UIView.animate(withDuration: 0.3, animations: {
            if hidden {
                self.inputViewBottomConstranit?.update(inset: -self.commentInputView.height)
                self.view.layoutIfNeeded()
//                self.navigationController?.navigationBar.y -= navHeight
//                setStatusBarBackground(ThemeStyle.style.value == .day ? .white : .black)
            }else { //显示
                self.inputViewBottomConstranit?.update(inset: 0)
                self.view.layoutIfNeeded()
                self.navigationController?.navigationBar.y = UIApplication.shared.statusBarFrame.height
                setStatusBarBackground(.clear)
            }
        })
    }
}

extension TopicDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        image = image.resized(by: 0.7)
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }

        let path = FileManager.document.appendingPathComponent("smfile.png")
        let error = FileManager.save(data, savePath: path)
        if let err = error {
            HUD.showTest(err)
            log.error(err)
        }
        uploadPictureHandle(path)
    }
}


// MARK: - 处理 Cell 内部、导航栏Item、SheetShare 的 Action
extension TopicDetailViewController {

    /// Cell 内部点击处理
    ///
    /// - Parameter type: 触发的类型
    private func tapHandle(_ type: TapType) {
        switch type {
        case .webpage(let url):
            openWebView(url: url)
        case .member(let member):
            let memberPageVC = MemberPageViewController(memberName: member.username)
            self.navigationController?.pushViewController(memberPageVC, animated: true)
        case .memberAvatarLongPress(let member):
            atMember(member.atUsername)
        case .imageURL(let src):
            showImageBrowser(imageType: .imageURL(src))
            setStatusBarBackground(.clear)
        case .image(let image):
            setStatusBarBackground(.clear)
            showImageBrowser(imageType: .image(image))
        case .node(let node):
            let nodeDetailVC = NodeDetailViewController(node: node)
            self.navigationController?.pushViewController(nodeDetailVC, animated: true)
        case .topic(let topicID):
            let topicDetailVC = TopicDetailViewController(topicID: topicID)
            self.navigationController?.pushViewController(topicDetailVC, animated: true)
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
            section1.append(ShareItem(icon: #imageLiteral(resourceName: "report"), title: "举报", type: .report))
        }

        let section2 = [
            ShareItem(icon: #imageLiteral(resourceName: "copy_link"), title: "复制链接", type: .copyLink),
            ShareItem(icon: #imageLiteral(resourceName: "safari"), title: "在 Safari 中打开", type: .safari),
            ShareItem(icon: #imageLiteral(resourceName: "share"), title: "分享", type: .share)
        ]

        let sheetView = ShareSheetView(sections: [section1, section2])
        sheetView.present()

        sheetView.shareSheetDidSelectedHandle = { [weak self] type in
            self?.shareSheetDidSelectedHandle(type)
        }
    }

    // 点击导航栏右侧的 更多
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
        case .report:
            reportHandle()
        case .copyLink:
            UIPasteboard.general.string = API.topicDetail(topicID: topicID, page: page).defaultURLString
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

// MARK: - 点击回复的相关操作
extension TopicDetailViewController {

    // 如果已经 at 的用户， 让 TextView 选中用户名
    private func atMember(_ atUsername: String?) {
        commentInputView.textView.becomeFirstResponder()
        guard var `atUsername` = atUsername, atUsername.trimmed.isNotEmpty else { return }

        if commentInputView.textView.text.contains(atUsername) {
            let range = commentInputView.textView.text.NSString.range(of: atUsername)
            commentInputView.textView.selectedRange = range
            return
        }

        if commentInputView.textView.text.last != " " {
            atUsername.insert(" ", at: commentInputView.textView.text.startIndex)
        }
        atUsername = Preference.shared.atMemberAddFloor ? atUsername + "#" + (selectComment?.floor ?? "") + " " : atUsername
        commentInputView.textView.insertText(atUsername)
    }

    private func atMembers() {
        // 解层
        let members = self.comments.flatMap { $0.member }
        let memberSet = Set<MemberModel>(members)
        let uniqueMembers = Array(memberSet).filter { $0.username != AccountModel.current?.username }
        let memberListVC = MemberListViewController(members: uniqueMembers )
        let nav = NavigationViewController(rootViewController: memberListVC)
        self.present(nav, animated: true, completion: nil)

        memberListVC.callback = { [weak self] members in
            guard let `self` = self else { return }
            self.commentInputView.textView.becomeFirstResponder()

            guard members.count.boolValue else { return }

            var atsWrapper = members
                .filter{ !self.commentInputView.textView.text.contains($0.atUsername) }
                .map { $0.atUsername }
                .joined()

            if self.commentInputView.textView.text.last != " " {
                atsWrapper.insert(" ", at: self.commentInputView.textView.text.startIndex)
            }
            self.commentInputView.textView.deleteBackward()
            self.commentInputView.textView.insertText(atsWrapper)
        }
    }

    @objc private func replyCommentAction() {
//        guard let atUsername = selectComment?.member.atUsername else { return }
//        commentInputView.textView.text = atUsername
//        commentInputView.textView.becomeFirstResponder()
        commentInputView.textView.text = ""
        atMember(selectComment?.member.atUsername)
    }

    @objc private func thankCommentAction() {
        guard let replyID = selectComment?.id,
            let token = topic?.token else {
                HUD.showText("操作失败")
                return
        }
        thankReply(replyID: replyID, token: token, success: { [weak self] in
            guard let `self` = self,
                let selectIndexPath = self.tableView.indexPathForSelectedRow else { return }
            HUD.showText("已成功发送感谢")
            self.dataSources[selectIndexPath.row].isThank = true
            // TODO: Bug 感谢之后刷新视图不正确
            self.tableView.reloadRows(at: [selectIndexPath], with: .none)
        }) { error in
            HUD.showText(error)
        }
    }

    @objc private func copyCommentAction() {
        guard let content = selectComment?.content else { return }
        UIPasteboard.general.string = content

        log.info(content)
    }

    @objc private func viewDialogAction() {
        guard let `selectComment` = selectComment else { return }
        let dialogs = CommentModel.atUsernameComments(comments: dataSources, currentComment: selectComment)

        guard dialogs.count.boolValue else {
            HUD.showText("没有找到与该用户有关的对话")
            return
        }

        let viewDialogVC = ViewDialogViewController(comments: dialogs)
        let nav = NavigationViewController(rootViewController: viewDialogVC)
        viewDialogVC.title = "有关 \(selectComment.member.username) 的对话"
        present(nav, animated: true, completion: nil)
    }

    @objc private func atMemberAction() {
        atMember(selectComment?.member.atUsername)
    }
}


// MARK: - Request
extension TopicDetailViewController {

    /// 获取主题详情
    func fetchTopicDetail(complete: (() -> Void)? = nil) {
        page = 1

        startLoading()

        topicDetail(topicID: topicID, success: { [weak self] topic, comments, maxPage in
            guard let `self` = self else { return }
            self.topic = topic
            self.dataSources = comments
            self.comments = comments
            self.tableView.endHeaderRefresh()
            self.maxPage = maxPage

            complete?()
            //            self.endLoading()
            }, failure: { [weak self] error in
                self?.errorMessage = error
                self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
                self?.tableView.endHeaderRefresh()
                self?.title = "加载失败"
        })
    }

    /// 获取更多评论
    func fetchMoreComment() {
        if page >= maxPage {
            self.tableView.endRefresh(showNoMore: self.page >= maxPage)
            return
        }

        page += 1

        topicMoreComment(topicID: topicID, page: page, success: { [weak self] comments in
            guard let `self` = self else { return }
            self.dataSources.append(contentsOf: comments)
            self.tableView.reloadData()
            self.tableView.endFooterRefresh(showNoMore: self.page >= self.maxPage)
            }, failure: { [weak self] error in
                self?.tableView.endFooterRefresh()
                self?.page -= 1
        })
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

        guard commentInputView.textView.text.trimmed.isNotEmpty else {
            HUD.showText("回复失败，您还没有输入任何内容", completionBlock: { [weak self] in
                self?.commentInputView.textView.becomeFirstResponder()
            })
            return
        }

        guard let once = topic.once else {
            HUD.showText("无法获取 once，请尝试重新登录", completionBlock: {
                presentLoginVC()
            })
            return
        }

        commentText = commentInputView.textView.text
        commentInputView.textView.text = nil

        HUD.show()
        comment(
            once: once,
            topicID: topicID,
            content: commentText, success: { [weak self] in
                guard let `self` = self else { return }
                HUD.showText("回复成功")
                HUD.dismiss()

                // TODO: 如果当前不是第一页，无法滚到回复位置, 并且会奔溃， 暂时处理只在第一页才滚动
                guard self.page == 1 else { return }
                self.fetchTopicDetail(complete: { [weak self] in
                    guard let `self` = self else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: self.dataSources.count - 2, section: 0), at: .bottom, animated: true)
                    self.setTabBarHiddn(true)
                })
        }) { [weak self] error in
            guard let `self` = self else { return }
            HUD.dismiss()
            HUD.showText(error)
            self.commentInputView.textView.text = self.commentText
            self.commentInputView.textView.becomeFirstResponder()
        }
    }

    // 上传配图请求
    private func uploadPictureHandle(_ fileURL: String) {
        HUD.show()

        uploadPicture(localURL: fileURL, success: { [weak self] url in
            log.info(url)
            self?.commentInputView.textView.insertText(url + " ")
            self?.commentInputView.textView.becomeFirstResponder()
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }

    /// 收藏、取消收藏请求
    private func favoriteHandle() {

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
    private func thankTopicHandle() {

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

        thankTopic(topicID: topicID, token: token, success: { [weak self] in
            HUD.showText("感谢已发送")
            self?.topic?.isThank = true
        }) { error in
            HUD.showText(error)
        }
    }

    /// 忽略主题请求
    private func ignoreTopicHandle() {
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

    /// 举报主题， 主要是过审核用
    private func reportHandle() {

        let alert = UIAlertController(title: "举报", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textView in
            textView.placeholder = "请填写举报原因"
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "确定举报", style: .destructive, handler: { _ in
            guard let text = alert.textFields?.first?.text, text.isNotEmpty else {
                HUD.showError("请输入举报原因")
                self.reportHandle()
                return
            }
            HUD.show()

            self.comment(
                once: self.topic?.once ?? "",
                topicID: self.topicID,
                content: "@Livid " + text, success: {
                    HUD.showText("举报成功")
                    HUD.dismiss()
            }) { error in
                log.error(error)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Action Handle
extension TopicDetailViewController {

    /// 打开系统分享
    func systemShare() {

        guard let url = API.topicDetail(topicID: topicID, page: page).url else { return }

        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: BrowserActivity.compatibleActivities)

        controller.excludedActivityTypes = [.postToFlickr, .postToVimeo, .message, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll]
        controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

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
        guard let url = API.topicDetail(topicID: topicID, page: page).url,
            UIApplication.shared.canOpenURL(url) else {
                HUD.showText("无法打开网页")
                return
        }
        UIApplication.shared.openURL(url)
    }
}

