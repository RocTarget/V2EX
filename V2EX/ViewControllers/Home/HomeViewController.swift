import UIKit
import SnapKit
import ViewAnimator
import StatefulViewController

class HomeViewController: BaseTopicsViewController {

    private lazy var tabView: NodeTabView = {
        let view = NodeTabView(
            frame: CGRect(x: 0,
                          y: 0,
                          width: UIScreen.screenWidth,
                          height: self.navigationController!.navigationBar.height),
            nodes: nodes)
        return view
    }()
    
    var nodes: [NodeModel] = [] {
        didSet {
            tabView.nodes = nodes
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.titleView = tabView
        
        tabView.valueChange = { [weak self] index in
            guard let `self` = self else { return }

            self.tableView.setContentOffset(CGPoint(x: -self.tableView.contentInset.left, y: -self.tableView.contentInset.top), animated: true)
            self.href = self.nodes[index].href
            self.fetchTopic()
        }
    }

    override func fetchData() {
        fetchIndexData()
    }

    func fetchIndexData() {
        startLoading()

        index(success: { [weak self] nodes, topics in
            guard let `self` = self else { return }

            self.nodes = nodes
            self.topics = topics
            self.endLoading()
            
            }, failure: { [weak self] error in
                HUD.dismiss()
                self?.endLoading()
                if let `emptyView` = self?.emptyView as? EmptyView {
                    emptyView.message = error
                }
        })
    }

    override func hasContent() -> Bool {
        return nodes.count.boolValue
    }

    override func setupStateFul() {
        loadingView = LoadingView(frame: tableView.frame)
        let ev = EmptyView(frame: tableView.frame)
        ev.retryHandle = { [weak self] in
            if self?.nodes.count == 0 {
                self?.fetchIndexData()
            } else {
                self?.startLoading()
                self?.fetchTopic()
            }
        }
        emptyView = ev
        setupInitialViewState()
    }
}

