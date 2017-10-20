import UIKit

class ReplyCell: BaseTableViewCell {

    private lazy var replyDesLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.hex(0xCCCCCC)
        view.font = UIFont.systemFont(ofSize: 14)
        view.numberOfLines = 0
        return view
    }()

    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()

    override func initialize() {
        separatorInset = .zero
        selectionStyle = .none
        contentView.addSubviews(replyDesLabel, contentLabel)
    }

    override func setupConstraints() {
        replyDesLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview().inset(15)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(replyDesLabel.snp.bottom).offset(10)
            $0.left.bottom.right.equalToSuperview().inset(15)
        }
    }

    public var message: MessageModel? {
        didSet {
            guard let `message` = message else { return }
            contentLabel.text = message.content
            replyDesLabel.text = message.replyTypeStr
            replyDesLabel.makeSubstringColor(message.topic.title, color: UIColor.hex(0x778087))
//            replyDesLabel.makeSubstringColor(message.time, color: UIColor.hex(0xe2e2e2))
        }
    }
}
