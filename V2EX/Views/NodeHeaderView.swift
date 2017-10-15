import UIKit

class NodeHeaderView: UICollectionReusableView {
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .gray
        return view
    }()
    
    public var title: String? {
        didSet {
            guard let `title` = title else { return }
            textLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Theme.Color.bgColor
        
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
