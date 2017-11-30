import UIKit

class NodeCollectViewController: DataViewController, NodeService {

    // MARK: - UI

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

    // MARK: - Propertys

    private var nodes: [NodeModel] = []

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNodes()
    }

    // MARK: - Setup

    override func setupSubviews() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: State Handle

    override func hasContent() -> Bool {
        return nodes.count.boolValue
    }

    override func loadData() {
        fetchNodes()
    }

    override func errorView(_ errorView: ErrorView, didTapActionButton sender: UIButton) {
        fetchNodes()
    }

    override func emptyView(_ emptyView: EmptyView, didTapActionButton sender: UIButton) {
        fetchNodes()
    }
}

// MARK: - Actions
extension NodeCollectViewController {

    /// 获取全部节点
    func fetchNodes() {
        startLoading()

        myNodes(success: { [weak self] nodes in
            self?.nodes = nodes
            self?.collectionView.reloadData()
            self?.endLoading()
        }) { [weak self] error in
            self?.errorMessage = error
            self?.endLoading(error: NSError(domain: "V2EX", code: -1, userInfo: nil))
        }
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
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

