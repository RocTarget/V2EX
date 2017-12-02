import UIKit

class FenCiCell: UICollectionViewCell {
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        //        view.font = UIFont.systemFont(ofSize: 15)
        view.textAlignment = .center
        view.textColor = Theme.Color.globalColor
        view.font = .preferredFont(forTextStyle: .body)
        if #available(iOS 10, *) {
            view.adjustsFontForContentSizeCategory = true
        }
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
        contentView.addSubview(textLabel)
        
        backgroundColor = .clear
        
        layer.borderColor = ThemeStyle.style.value.globalColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        selectedBackgroundView = nil
        
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        ThemeStyle.style.asObservable()
//            .subscribeNext { [weak self] theme in
//                self?.backgroundColor = theme == .day ? theme.bgColor : theme.cellBackgroundColor
//                self?.textLabel.textColor = theme.somberColor
//            }.disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = UIColor.red.cgColor
                textLabel.textColor = UIColor.red
            } else {
                layer.borderColor = ThemeStyle.style.value.globalColor.cgColor
                textLabel.textColor = ThemeStyle.style.value.globalColor
            }
        }
    }
}
