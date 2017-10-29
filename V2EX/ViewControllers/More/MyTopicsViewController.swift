import UIKit

class MyTopicsViewController: BaseTopicsViewController, MemberService {

    var username: String
    
    public var scrollViewDidScroll: ((UIScrollView) -> Void)?

    init(username: String) {
        self.username = username
        super.init(href: "")
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
        startLoading()
        
        memberTopics(
            username: username,
            success: {[weak self] topics in
                self?.topics = topics
                self?.endLoading()
                self?.tableView.endRefresh()
        }) { [weak self] error in
            self?.tableView.endRefresh()
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.errorMessage = error
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}
