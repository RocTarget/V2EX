import UIKit

class TopicFavoriteViewController: BaseTopicsViewController, AccountService {


    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.addFooterRefresh { [weak self] in
            self?.fetchMoreFavoriteTopic()
        }
    }
    
    override func loadData() {
        fetchFavoriteTopic()
    }
    
    private func fetchFavoriteTopic() {
        page = 1
        startLoading()
        
        
        myFavorite(page: page, success: { [weak self] topics, maxPage in
            self?.maxPage = maxPage
            self?.topics = topics
            self?.endLoading()
            self?.tableView.endHeaderRefresh()
        }, failure: { [weak self] error in
            self?.tableView.endHeaderRefresh()
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
            self?.errorMessage = error
        })
    }
    
    func fetchMoreFavoriteTopic() {
        if page >= maxPage {
            tableView.endRefresh(showNoMore: true)
            return
        }
        
        page += 1
        
        startLoading()
        
        myFavorite(page: page, success: { [weak self] topics, maxPage in
            guard let `self` = self else { return }
            self.topics.append(contentsOf: topics)
            self.tableView.reloadData()
            self.tableView.endRefresh(showNoMore: maxPage < self.page)
        }) { [weak self] error in
            self?.tableView.endFooterRefresh()
            self?.page -= 1
        }
    }
}
