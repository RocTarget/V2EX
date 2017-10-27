import UIKit

class MessageViewController: DataViewController, AccountService {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(cellWithClass: MessageCell.self)
        view.estimatedRowHeight = 120
        view.rowHeight = UITableViewAutomaticDimension
        view.backgroundColor = .clear
        self.view.addSubview(view)
        view.hideEmptyCells()
        return view
    }()

    private weak var replyMessageViewController: ReplyMessageViewController?

    private var messages: [MessageModel] = []

    private var page = 1, maxPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNotifications()

        tableView.addHeaderRefresh { [weak self] in
            self?.fetchNotifications()
        }

        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreNotifications()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 有未读通知, 主动刷新
        guard isLoad, let _ = tabBarItem.badgeValue else { return }

        tableView.startHeaderRefresh()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setupRx() {

        NotificationCenter.default.rx
            .notification(Notification.Name.V2.LoginSuccessName)
            .subscribeNext { [weak self] _ in
                self?.fetchNotifications()
            }.disposed(by: rx.disposeBag)
    }

    // MARK: States Handle

    override func loadData() {
        fetchNotifications()
    }

    func fetchNotifications() {

        guard AccountModel.isLogin else {
            endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            status = .noAuth
            return
        }

        page = 1

        startLoading()

        notifications(page: page, success: { [weak self] messages, maxPage in
            guard let `self` = self else { return }
            self.messages = messages
            self.maxPage = maxPage
            self.endLoading()
            self.tableView.reloadData()
            self.tabBarItem.badgeValue = nil
            self.tableView.endRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.errorMessage = error
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.tableView.endHeaderRefresh()
        }
    }

    func fetchMoreNotifications() {
        page += 1

        startLoading()

        notifications(page: page, success: { [weak self] messages, maxPage in
            guard let `self` = self else { return }
            self.messages.append(contentsOf: messages)
            self.tableView.reloadData()
            self.tableView.endRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.tableView.endRefresh()
            self?.page -= 1
        }
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton _: UIButton) {
        if status == .noAuth {
            presentLoginVC()
            return
        }
        fetchNotifications()
    }

    override func hasContent() -> Bool {
        return messages.count.boolValue
    }

    private func deleteMessages(_ message: MessageModel) {
        guard let id = message.id,
            let once = message.once else {
            HUD.showText("操作失败，无法获取消息 ID 或 once")
            return
        }
        deleteNotification(notifacationID: id, once: once, success: {

        }) { error in
            HUD.showText(error)
        }
    }

    /// TODO: 回复消息
    private func replyMessage(_ message: MessageModel) {
        if replyMessageViewController == nil {
            let replyMessageVC = ReplyMessageViewController()
            replyMessageVC.view.alpha = 0
            self.replyMessageViewController = replyMessageVC
            addChildViewController(replyMessageVC)
            self.view.addSubview(replyMessageVC.view)
        }

        replyMessageViewController?.message = message
    }
}


extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MessageCell.self)!
        cell.message = messages[indexPath.row]
        cell.avatarTapHandle = { [weak self] cell in
            guard let `self` = self,
                let row = tableView.indexPath(for: cell)?.row else {
                    return
            }
            log.info(row, self)
            //            let message = self.messages[row]
            //            log.info(message.user.username)
            //            let memberVC = MemberPageViewController(member: member)
            //            self.navigationController?.pushViewController(memberVC, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let topicID = messages[indexPath.row].topic.topicID else { return }
        let topicDetailVC = TopicDetailViewController(topicID: topicID)
        navigationController?.pushViewController(topicDetailVC, animated: true)
    }


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let replyAction = UITableViewRowAction(
            style: .default,
            title: "回复") { _, indexPath in
                let message = self.messages[indexPath.row]
                self.replyMessage(message)
        }
        replyAction.backgroundColor = UIColor.hex(0x0058E5)

        let deleteAction = UITableViewRowAction(
            style: .destructive,
            title: "删除") { _, indexPath in
                let message = self.messages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.deleteMessages(message)
        }
        return [deleteAction, replyAction]
    }
}
