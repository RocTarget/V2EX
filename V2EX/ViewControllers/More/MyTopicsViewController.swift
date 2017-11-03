import UIKit

class MyTopicsViewController: BaseTopicsViewController, MemberService {

    var username: String
    
    public var scrollViewDidScroll: ((UIScrollView) -> Void)?

    init(username: String) {
        self.username = username
        super.init(href: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "edit"), style: .plain, action: { [weak self] in
            let viewController = CreateTopicViewController()
            self?.navigationController?.pushViewController(viewController, animated: true)
        })
    }

    override func setupRefresh() {
        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreTopic()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchTopic()
    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        fetchTopic()
    }

    override func fetchTopic() {
        page = 1
        startLoading()
        
        memberTopics(
            username: username,
            page: page,
            success: {[weak self] topics, maxPage in
                self?.topics = topics
                self?.endLoading()
                self?.tableView.endRefresh()
                self?.maxPage = maxPage
        }) { [weak self] error in
            self?.tableView.endRefresh()
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.errorMessage = error
        }
    }


    private func fetchMoreTopic() {
        if self.page >= maxPage {
            tableView.endRefresh(showNoMore: true)
            return
        }
        page += 1

        memberTopics(
            username: username,
            page: page,
            success: { [weak self] topics, maxPage in

            guard let `self` = self else { return }
            self.topics.append(contentsOf: topics)
            self.tableView.reloadData()
            self.tableView.endRefresh(showNoMore: maxPage < self.page)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
            self?.page -= 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}
