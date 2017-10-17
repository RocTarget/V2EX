import UIKit

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

        fetchNodes()
    }

    override func setupSubviews() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func fetchNodes() {
        HUD.show()

        myNodes(success: { [weak self] nodes in
            self?.nodes = nodes
            HUD.dismiss()
            self?.collectionView.reloadData()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
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
