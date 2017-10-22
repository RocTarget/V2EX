import UIKit
import StatefulViewController

class NodeDetailViewController: BaseTopicsViewController, NodeService {

    public var node: NodeModel {
        didSet {
            title = node.name
        }
    }
    
    init(node: NodeModel) {
        self.node = node
        super.init(href: node.path)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func fetchData() {
        startLoading()
        fetchNodeDetail()
    }
    
    func fetchNodeDetail() {

        nodeDetail(
            node: node,
            success: { [weak self] node, topics in
                self?.node = node
                self?.topics = topics
                self?.refreshControl.endRefreshing()
                self?.endLoading()
        }) { [weak self] error in
            self?.refreshControl.endRefreshing()

            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.message = error
            }
            self?.endLoading()
        }
    }
}
