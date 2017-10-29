import UIKit

class MyReplyViewController: DataViewController, MemberService {

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

    public var scrollViewDidScroll: ((UIScrollView) -> Void)?
    
    public var username: String

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

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: State Handle

    override func loadData() {

        fetchReplys()
    }

    override func hasContent() -> Bool {
        return replys.count.boolValue
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchReplys()
    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        fetchReplys()
    }

    func fetchReplys() {
        startLoading()
        memberReplys(username: username, success: { [weak self] replys in
            self?.replys = replys
            self?.endLoading()
        }) { [weak self] error in
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.errorMessage = error
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}
