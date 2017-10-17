import UIKit

class EmptyView: BasePlaceholderView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = UIColor.gray
        view.fontSize = 14
        return view
    }()
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    init(frame: CGRect, title: String? = nil, message: String? = nil, image: UIImage? = nil) {
        super.init(frame: frame)
        
        if let title = title {
            titleLabel.text = title
            addSubviews(titleLabel)
        }
        
        if let message = message {
            messageLabel.text = message
            addSubviews(messageLabel)
        }
        
        if let image = image {
            imageView.image = image
            addSubviews(imageView)
            
            imageView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-40)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            if image != nil {
                $0.centerY.equalTo(imageView.snp.bottom).offset(20)
            } else {
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
