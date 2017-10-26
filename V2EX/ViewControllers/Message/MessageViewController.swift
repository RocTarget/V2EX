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
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()
    
    private var messages: [MessageModel] = []
    
//    /// 标记有新消失时是否刷新，第一次加载不请求
//    private var isLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNotifications()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        isLoad = true
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// 有未读通知, 主动刷新
        guard isLoad, let _ = tabBarItem.badgeValue else { return }
        
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    override func setupSubviews() {
        tableView.addSubview(refreshControl)
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
                self?.fetchNotifications()
            }.disposed(by: rx.disposeBag)
        
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

        startLoading()

        notifications(success: { [weak self] messages in
            self?.messages = messages
            self?.endLoading()
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
            self?.tabBarItem.badgeValue = nil
        }) { [weak self] error in
            self?.errorMessage = error
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.refreshControl.endRefreshing()
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

    /// TODO: 删除消息
    private func deleteMessages() {

    }

    /// TODO: 回复消息
    private func replyMessage() {

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
                log.info("回复评论")
                self.replyMessage()
        }
        replyAction.backgroundColor = UIColor.hex(0x0058E5)

        let deleteAction = UITableViewRowAction(
            style: .destructive,
            title: "删除") { _, indexPath in
                self.messages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.deleteMessages()
        }
        return [deleteAction, replyAction]
    }
}
