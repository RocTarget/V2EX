import UIKit


enum EmptyType {
    case normal, empty, error, notNet

    var image: UIImage {
        switch self {
        case .empty, .normal: return #imageLiteral(resourceName: "hg-no_results")
        case .error: return #imageLiteral(resourceName: "hg-error")
        case .notNet: return #imageLiteral(resourceName: "hg-no_connection")
        }
    }

    var title: String {
        switch self {
        case .empty, .normal:
            return "没有数据"
        case .error:
            return "请求失败"
        case .notNet:
            return "没有网络连接"
        }
    }

    var allowRetry: Bool {
        switch self {
        case .normal, .empty:
            return false
        default:
            return true
        }
    }
}

class EmptyView: BasePlaceholderView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.font = UIFont.boldSystemFont(ofSize: 20)
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = UIColor.hex(0x8E8A8F)
        view.fontSize = 14
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var retryBtn: UIButton = {
        let view = UIButton()
        view.setTitle("重试", for: .normal)
        view.backgroundColor = Theme.Color.globalColor
        view.setCornerRadius = 20
        view.addTarget(self, action: #selector(retryBtnClick), for: .touchUpInside)
        return view
    }()

    public var message: String? {
        didSet {
            messageLabel.text = message
        }
    }

    public var type: EmptyType = .normal {
        didSet {
            imageView.image = type.image
            retryBtn.isHidden = !type.allowRetry
            titleLabel.text = type.title
            animate()
        }
    }

    public var retryHandle: Action?

    init(frame: CGRect, message: String? = nil, type: EmptyType = .error) {
        super.init(frame: frame)

        addSubviews(titleLabel, messageLabel, imageView, retryBtn)

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.size.equalTo(100)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(20)
        }

        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(50)
        }

        retryBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }

        titleLabel.text = type.title
        messageLabel.text = message
        imageView.image = type.image
        retryBtn.isHidden = !type.allowRetry
    }

    func animate() {
        let rotate = CGAffineTransform(rotationAngle: -0.2)
        let stretchAndRotate = rotate.scaledBy(x: 0.5, y: 0.5)
        imageView.transform = stretchAndRotate
        imageView.alpha = 0.5
        UIView.animate(
            withDuration: 1.5,
            delay: 0.0,
            usingSpringWithDamping: 0.45,
            initialSpringVelocity: 10.0,
            options:[.curveEaseOut],
            animations: {
                self.imageView.alpha = 1.0
                let rotate = CGAffineTransform(rotationAngle: 0.0)
                let stretchAndRotate = rotate.scaledBy(x: 1.0, y: 1.0)
                self.imageView.transform = stretchAndRotate

        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func retryBtnClick() {
        retryHandle?()
    }

    override func didMoveToSuperview() {
        animate()
    }
}
