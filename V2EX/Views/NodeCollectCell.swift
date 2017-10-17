import UIKit

class NodeCollectCell: UICollectionViewCell {

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.textColor = UIColor.hex(0x778087)
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()

    private lazy var commentBtn: UIButton = {
        let view = UIButton()
        view.setTitleColor(UIColor.hex(0xcccccc), for: .normal)
        view.setImage(#imageLiteral(resourceName: "dialog"), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubviews(
            iconView,
            titleLabel,
            commentBtn
        )
    }

    func setupLayout() {
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(73)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(3)
        }

        commentBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }

    public var node: NodeModel? {
        didSet {
            guard let `node` = node else { return }

            titleLabel.text = node.name
            iconView.setImage(urlString: node.iconFullURL)
            commentBtn.setTitle(node.comments, for: .normal)
        }
    }
}
