import UIKit
import StatefulViewController

class NodesViewController: BaseViewController, NodeService {
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        layout.minimumInteritemSpacing = 15
        layout.headerReferenceSize = CGSize(width: self.view.width, height: 40)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.dataSource = self
        view.delegate = self
        view.register(NodeCell.self, forCellWithReuseIdentifier: NodeCell.description())
        view.register(NodeHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NodeHeaderView.description())
        return view
    }()
    
    private var nodeCategorys: [NodeCategoryModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "节点导航"
    }

    override func setupSubviews() {

        view.addSubview(collectionView)

        fetchNodeCategory()
        setupStateFul()
    }

    func fetchNodeCategory() {
        startLoading()

        nodeNavigation(success: { [weak self] cates in
            self?.nodeCategorys = cates
            self?.endLoading()
        }) { [weak self] error in
            if let `emptyView` = self?.emptyView as? EmptyView {
                emptyView.message = error
            }
            self?.endLoading()
        }
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NodesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return nodeCategorys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nodeCategorys[section].nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NodeCell.description(), for: indexPath) as! NodeCell
        cell.node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NodeHeaderView.description(), for: indexPath) as! NodeHeaderView
        headerView.title = nodeCategorys[indexPath.section].name
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        let nodeDetailVC = NodeDetailViewController(node: node)
        navigationController?.pushViewController(nodeDetailVC, animated: true)
    }
}

extension NodesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let node = nodeCategorys[indexPath.section].nodes[indexPath.row]
        let w = node.name.toWidth(fontSize: 16)
        return CGSize(width: w, height: 30)
    }
}

extension NodesViewController: StatefulViewController {

    func hasContent() -> Bool {
        return nodeCategorys.count.boolValue
    }

    func setupStateFul() {
        loadingView = LoadingView(frame: collectionView.frame)
        let ev = EmptyView(frame: collectionView.frame)
        ev.retryHandle = { [weak self] in
            self?.fetchNodeCategory()
        }
        emptyView = ev
        setupInitialViewState()
    }
}

