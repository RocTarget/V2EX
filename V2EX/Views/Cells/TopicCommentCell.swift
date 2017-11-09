import UIKit
import SnapKit
import YYText

class TopicCommentCell: BaseTableViewCell {

    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.setCornerRadius = 5
        return view
    }()

    private lazy var usernameLaebl: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()

    private lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.hex(0xCCCCCC)
        return view
    }()

    private lazy var floorLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.hex(0xCCCCCC)
        return view
    }()

    private lazy var hostLabel: UILabel = {
        let view = UILabel()
        view.text = "楼主"
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.hex(0x969696)
        view.isHidden = true
        return view
    }()
    
    private lazy var thankLabel: UILabel = {
        let view = UILabel()
        view.text = "♥"
        view.font = UIFont.systemFont(ofSize: 13)
        view.textColor = UIColor.hex(0xcccccc)
        return view
    }()

    private lazy var contentLabel: YYLabel = {
        let view = YYLabel()
        view.numberOfLines = 0
        view.preferredMaxLayoutWidth = Constants.Metric.screenWidth - 30;
        view.displaysAsynchronously = true
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Color.borderColor
        return view
    }()

    private var thankLabelLeftConstraint: Constraint?
    
    public var tapHandle: ((_ type: TapType) -> Void)?

    public var hostUsername: String?

    public var comment: CommentModel? {
        didSet {
            guard let `comment` = comment else { return }

            avatarView.setImage(urlString: comment.member.avatarSrc, placeholder: #imageLiteral(resourceName: "avatarRect"))
            usernameLaebl.text = comment.member.username
            floorLabel.text = comment.floor + " 楼"
            timeLabel.text =  comment.publicTime

            contentLabel.textLayout = comment.textLayout

            // TODO: Bug - 楼主显示\隐藏 状态不正确
            hostLabel.isHidden = (hostUsername ?? "")  != comment.member.username

            var thankText = comment.thankCount
            if comment.isThank {
                thankText?.append("  已感谢")
            }
            thankLabel.text = thankText
            
            thankLabelLeftConstraint?.update(offset: hostLabel.isHidden ? -25 : 10)

            guard let attachments = contentLabel.textLayout?.attachments else { return }
            for attachment in attachments {
                guard let imageView = attachment.content as? ImageAttachment else { continue }
                imageView.delegate = self
            }
        }
    }

    override func initialize() {
        selectionStyle = .none
        
        let avatarTapGesture = UITapGestureRecognizer()
        avatarView.addGestureRecognizer(avatarTapGesture)

        let avatarLongPressGesture = UILongPressGestureRecognizer()
        avatarLongPressGesture.minimumPressDuration = 0.25
        avatarView.addGestureRecognizer(avatarLongPressGesture)

        let textViewLongPressGesture = UILongPressGestureRecognizer()
        contentLabel.addGestureRecognizer(textViewLongPressGesture)

        avatarTapGesture.rx
            .event
            .subscribeNext { [weak self] _ in
                guard let member = self?.comment?.member else { return }
                self?.tapHandle?(.member(member))
            }.disposed(by: rx.disposeBag)

        avatarLongPressGesture.rx
            .event
            .subscribeNext { [weak self] gesture in

                guard gesture.state == .began else { return }
                guard let member = self?.comment?.member else { return }
                self?.tapHandle?(.memberAvatarLongPress(member))
        }.disposed(by: rx.disposeBag)
        
        contentView.addSubviews(
            avatarView,
            usernameLaebl,
            timeLabel,
            floorLabel,
            hostLabel,
            thankLabel,
            contentLabel,
            lineView
        )

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.contentLabel.textColor = theme.titleColor
                self?.usernameLaebl.textColor = theme.titleColor
                self?.lineView.backgroundColor = theme.borderColor
            }.disposed(by: rx.disposeBag)
    }

    override func setupConstraints() {
        avatarView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(48)
        }

        usernameLaebl.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.top.equalTo(avatarView).offset(3)
        }

        hostLabel.snp.makeConstraints {
            $0.left.equalTo(usernameLaebl.snp.right).offset(10)
            $0.centerY.equalTo(usernameLaebl)
        }

        floorLabel.snp.makeConstraints {
            $0.left.equalTo(usernameLaebl)
            $0.bottom.equalTo(avatarView).inset(3)
        }

        timeLabel.snp.makeConstraints {
            $0.left.equalTo(floorLabel.snp.right).offset(10)
            $0.centerY.equalTo(floorLabel)
        }
        
        thankLabel.snp.makeConstraints {
            thankLabelLeftConstraint = $0.left.equalTo(hostLabel.snp.right).offset(10).constraint
            $0.centerY.equalTo(usernameLaebl)
        }

        contentLabel.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(15)
            $0.top.equalTo(avatarView.snp.bottom).offset(10)
        }

        lineView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}

extension TopicCommentCell: ImageAttachmentDelegate {
    func imageAttachmentTap(_ imageView: UIImageView) {
        guard let image = imageView.image else { return }
        tapHandle?(.image(image))
    }
}
