import UIKit

class NodeCell: UICollectionViewCell {

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15)
        view.textAlignment = .center
        view.textColor = Theme.Color.globalColor
        return view
    }()
    
    public var node: NodeModel? {
        didSet {
            guard let `node` = node else { return }
            
            textLabel.text = node.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)

        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
