import UIKit
import StatefulViewController

class NodeCollectViewController: BaseViewController, NodeService {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.width / 3, height: 150)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(NodeCollectCell.self, forCellWithReuseIdentifier: NodeCollectCell.description())
        self.view.addSubview(view)
        return view
    }()

    private var nodes: [NodeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startLoading()
        setupStateFul()
        fetchNodes()
    }

    override func setupSubviews() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func fetchNodes() {

        myNodes(success: { [weak self] nodes in
            self?.nodes = nodes
            self?.collectionView.reloadData()
            self?.endLoading()
        }) { [weak self] error in
            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.message = error
            }
            self?.endLoading()
        }
    }
}

extension NodeCollectViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NodeCollectCell.description(), for: indexPath) as! NodeCollectCell
        cell.node = nodes[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = nodes[indexPath.row]
        let nodeDetailVC = NodeDetailViewController(node: node)
        navigationController?.pushViewController(nodeDetailVC, animated: true)
    }
}


// MARK: - StatefulViewController
extension NodeCollectViewController: StatefulViewController {
    
    func hasContent() -> Bool {
        return nodes.count.boolValue
    }
    
    func setupStateFul() {
        loadingView = LoadingView(frame: collectionView.frame)
        let ev = EmptyView(frame: collectionView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchNodes()
        }
        emptyView = ev
        setupInitialViewState()
    }
}
