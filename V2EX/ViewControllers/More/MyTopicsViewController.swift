import UIKit

class MyTopicsViewController: BaseTopicsViewController {

    var username: String

    init(username: String) {
        self.username = username
        super.init(href: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func fetchTopic() {
        memberTopics(
            username: username,
            success: {[weak self] topics in
                self?.topics = topics
                self?.endLoading()
                self?.refreshControl.endRefreshing()
        }) { [weak self] error in
            self?.refreshControl.endRefreshing()
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            if let `errorView` = self?.errorView as? EmptyView {
                errorView.message = error
            }
        }
    }
}
