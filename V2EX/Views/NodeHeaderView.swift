import UIKit

class NodeHeaderView: UICollectionReusableView {
    private lazy var textLabel: UIInsetLabel = {
        let view = UIInsetLabel()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = Theme.Color.globalColor
        view.borderLeft = Border(size: 3, color: Theme.Color.globalColor)
        view.contentInsetsLeft = 9
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
        
        backgroundColor = .clear
        
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.centerY.equalToSuperview()
        }

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.textLabel.textColor = theme.somberColor
                self?.textLabel.borderLeft = Border(size: 3, color: theme.somberColor)
            }.disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
