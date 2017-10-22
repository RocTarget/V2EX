import UIKit
import StatefulViewController

class MyReplyViewController: BaseViewController, TopicService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.estimatedRowHeight = 120
        view.rowHeight = UITableViewAutomaticDimension
        view.backgroundColor = .clear
        view.hideEmptyCells()
        view.register(cellWithClass: ReplyCell.self)
        self.view.addSubview(view)
        return view
    }()

    var username: String

    private var replys: [MessageModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupSubviews() {
        fetchReplys()
        setupStateFul()
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func fetchReplys() {
        startLoading()

        memberReply(username: username, success: { [weak self] replys in
            self?.replys = replys
            self?.endLoading()
        }) { [weak self] error in
            self?.endLoading()
            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.message = error
            }
        }
    }

}

extension MyReplyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ReplyCell.self)!
        cell.message = replys[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = replys[indexPath.row].topic

        guard let topicId = topic.topicID else {
            HUD.showText("操作失败，无法解析主题 ID")
            return
        }
        
        let topicDetailVC = TopicDetailViewController(topicID: topicId)
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }

}

extension MyReplyViewController: StatefulViewController {
    func hasContent() -> Bool {
        return replys.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchReplys()
        }
        emptyView = ev
        setupInitialViewState()
    }
}
