import UIKit
import PullToRefreshKit

extension UIScrollView {

    func addHeaderRefresh(handle: @escaping Action) {
        setUpHeaderRefresh(handle)
//        setUpHeaderRefresh(ElasticRefreshHeader(), action: handle)
    }

    func addFooterRefresh(handle: @escaping Action) {
        setUpFooterRefresh(VFooterRefresh(), action: handle)
    }

    func endHeaderRefresh() {
        endHeaderRefreshing()
        resetFooterToDefault()
    }

    func endFooterRefresh(showNoMore: Bool = false) {
        endFooterRefreshing()
        
        if showNoMore {
            endFooterRefreshingWithNoMoreData()
        }
    }

    func endRefresh(showNoMore: Bool = false) {

        guard showNoMore else {
            endHeaderRefreshing()
            endFooterRefreshing()
            return
        }
        endFooterRefresh(showNoMore: showNoMore)
    }

}
