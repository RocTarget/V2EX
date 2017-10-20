import UIKit
import StatefulViewController

class MessageViewController: BaseViewController, AccountService {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addSubview(refreshControl)

        fetchNotifications()
        setupStateFul()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func fetchNotifications() {

        startLoading()

        notifications(success: { [weak self] messages in
            self?.messages = messages
            self?.endLoading()
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }) { [weak self] error in
            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.message = error
                emptyView.type = .error
            }
            self?.endLoading()
            self?.refreshControl.endRefreshing()
        }
    }

    override func setupRx() {

        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribeNext { [weak self] in
                self?.fetchNotifications()
            }.disposed(by: rx.disposeBag)
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
//            let message = self.messages[row]
//            log.info(message.user.username)
            let memberVC = MemberPageViewController()
            self.navigationController?.pushViewController(memberVC, animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let topicID = messages[indexPath.row].topic.topicId else { return }
        let topicDetailVC = TopicDetailViewController(topicID: topicID)
        navigationController?.pushViewController(topicDetailVC, animated: true)
    }
}

extension MessageViewController: StatefulViewController {

    func hasContent() -> Bool {
        return messages.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchNotifications()
        }
        emptyView = ev
        setupInitialViewState()
    }
}

