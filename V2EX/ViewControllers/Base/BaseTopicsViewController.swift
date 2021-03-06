import UIKit

class BaseTopicsViewController: DataViewController, TopicService {

    internal lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(cellWithClass: TopicCell.self)
        view.keyboardDismissMode = .onDrag
        view.hideEmptyCells()
        self.view.addSubview(view)
        return view
    }()

    var topics: [TopicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    public var href: String

    internal var page = 1, maxPage = 1

    init(href: String) {
        self.href = href
        super.init(nibName: nil, bundle: nil)
    }

    convenience init() {
        self.init(href: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupSubviews() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        setupRefresh()
    }

    func setupRefresh() {
        tableView.addHeaderRefresh { [weak self] in
            self?.fetchTopic()
        }

        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreTopic()
        }
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(0.5).priority(.high)
        }
    }

    override func setupTheme() {
        super.setupTheme()

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
            }.disposed(by: rx.disposeBag)
    }
    // MARK: State Handle

    override func loadData() {
        fetchData()
    }

    override func hasContent() -> Bool {
        return topics.count.boolValue
    }

    func fetchData() {
        startLoading()
        fetchTopic()
    }
    
    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchData()
    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        fetchData()
    }

    func fetchTopic() {
        page = 1

        topics(href: href, success: { [weak self] topic in
            self?.topics = topic
            self?.endLoading()
            self?.tableView.endHeaderRefresh()
            }, failure: { [weak self] error in
                self?.tableView.endHeaderRefresh()
                self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
                self?.errorMessage = error
        })
    }

    private func fetchMoreTopic() {
        let allHref = "/?tab=all"
        let isAllowRefresh = href.hasPrefix(allHref)
        if isAllowRefresh == false {
            tableView.endFooterRefresh(showNoMore: !isAllowRefresh)
        }

        guard isAllowRefresh else { return }

        recentTopics(page: page, success: { [weak self] topics, maxPage in
            guard let `self` = self else { return }
            self.page += 1
            self.maxPage = maxPage

            // 数据去重
            let ts = topics.filter({ rhs -> Bool in
                !self.topics.contains(where: { lhs -> Bool in
                    return lhs.title == rhs.title
                })
            })
            self.topics.append(contentsOf: ts)
            self.tableView.endFooterRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
            HUD.showError(error)
        }
    }


    func tapHandle(_ type: TapType) {
        switch type {
        case .member(let member):
            let memberPageVC = MemberPageViewController(memberName: member.username)
            navigationController?.pushViewController(memberPageVC, animated: true)
        case .node(let node):
            let nodeDetailVC = NodeDetailViewController(node: node)
            navigationController?.pushViewController(nodeDetailVC, animated: true)
        default:
            break
        }
    }
}

extension BaseTopicsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TopicCell.self)!
        cell.topic = topics[indexPath.row]
        cell.tapHandle = { [weak self] type in
            self?.tapHandle(type)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        let topic = topics[indexPath.row]
        guard let topicId = topic.topicID else {
            HUD.showError("操作失败，无法解析主题 ID")
            return
        }
        let topicDetailVC = TopicDetailViewController(topicID: topicId)
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return topics[indexPath.row].cellHeight
    }
}

extension BaseTopicsViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let topicID = topics[indexPath.row].topicID else { return nil }

        let viewController = TopicDetailViewController(topicID: topicID)
        previewingContext.sourceRect = cell.frame
        return viewController
    }
}
