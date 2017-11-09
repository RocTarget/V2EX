import UIKit

class NodeDetailViewController: BaseTopicsViewController, NodeService, AccountService {

    private lazy var favoriteTopicItem: UIBarButtonItem = {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "favoriteNav"), style: .plain)
    }()

    public var node: NodeModel {
        didSet {
            title = node.title
            favoriteTopicItem.image = (node.isFavorite ?? false) ? #imageLiteral(resourceName: "unfavoriteNav") : #imageLiteral(resourceName: "favoriteNav")
        }
    }

    init(node: NodeModel) {
        self.node = node
        super.init(href: node.path)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreTopic()
        }

        guard AccountModel.isLogin else { return }

        let newTopicItem = UIBarButtonItem(image: #imageLiteral(resourceName: "edit"), style: .plain, action: { [weak self] in
            let createTopicVC = CreateTopicViewController()
            createTopicVC.node = self?.node
            self?.navigationController?.pushViewController(createTopicVC, animated: true)
        })

        navigationItem.rightBarButtonItems = [newTopicItem, favoriteTopicItem]
    }

    override func setupRx() {
        favoriteTopicItem.rx
            .tap
            .subscribeNext { [weak self] in
                self?.favoriteHandle()
            }.disposed(by: rx.disposeBag)

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tableView.separatorColor = theme.borderColor
            }.disposed(by: rx.disposeBag)
    }

    override func loadData() {
        fetchNodeDetail()
    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        loadData()
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        loadData()
    }
}

extension NodeDetailViewController {

    func fetchNodeDetail() {
        page = 1
        startLoading()

        nodeDetail(
            page: page,
            node: node,
            success: { [weak self] node, topics, maxPage in
                guard let `self` = self else { return }
                self.maxPage = maxPage
                self.node = node
                self.topics = topics
                self.tableView.endFooterRefresh()
                self.endLoading()
                self.tableView.endRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
            self?.errorMessage = error
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
        }
    }

    func fetchMoreTopic() {
        page += 1

        nodeDetail(
            page: page,
            node: node,
            success: { [weak self] _, topics, maxPage in
                guard let `self` = self else { return }
                self.maxPage = maxPage
                self.topics.append(contentsOf: topics)
                self.tableView.endFooterRefresh()
                self.endLoading()
                self.tableView.endRefresh(showNoMore: self.page >= maxPage)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
            self?.errorMessage = error
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
        }
    }

    private func favoriteHandle() {
        guard let href = node.favoriteOrUnfavoriteHref else {
            HUD.showText("收藏失败，请重试")
            return
        }

        favorite(href: href, success: { [weak self] in
            guard let `self` = self else { return }
            self.node.isFavorite = !self.node.isFavorite!
            HUD.showText("已成功\(self.node.isFavorite! ? "收藏" : "取消收藏") \(self.node.title)")
            self.favoriteTopicItem.image = self.node.isFavorite! ? #imageLiteral(resourceName: "unfavoriteNav") : #imageLiteral(resourceName: "favoriteNav")
        }) { error in
            HUD.showText(error)
        }
    }
}
