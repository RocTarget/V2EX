import UIKit

class TopicCell: BaseTableViewCell {

    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var nodeLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.fontSize = 16
        view.textColor = UIColor.hex(0x778087)
        return view
    }()
    
    private lazy var lastReplyTimeLabel: UILabel = {
        let view = UILabel()
        return view
    }()

    private lazy var replyCountLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    override func initialize() {
        contentView.addSubviews(
            avatarView,
            usernameLabel,
            nodeLabel,
            titleLabel,
            lastReplyTimeLabel,
            replyCountLabel)
    }
    
    override func setupConstraints() {
        
        avatarView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.top.equalTo(avatarView).offset(5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(15)
            $0.top.equalTo(avatarView.snp.bottom).offset(15)
        }
        
        nodeLabel.snp.makeConstraints {
            $0.left.bottom.equalToSuperview().inset(15)
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        
        lastReplyTimeLabel.snp.makeConstraints {
            $0.left.equalTo(nodeLabel.snp.right).offset(10)
            $0.bottom.equalTo(nodeLabel)
        }
        
        replyCountLabel.snp.makeConstraints {
            $0.left.equalTo(lastReplyTimeLabel.snp.right).offset(10)
            $0.bottom.equalTo(nodeLabel)
        }
    }
    
    var topic: TopicModel? {
        didSet {
            guard let `topic` = topic else { return }
            avatarView.setImage(urlString: topic.user.avatarSrc)
            usernameLabel.text = topic.user.name
            titleLabel.text = topic.title
            nodeLabel.text = topic.node.name
            lastReplyTimeLabel.text = topic.lastReplyTime
            replyCountLabel.text = topic.replyCount.description
            replyCountLabel.isHidden = topic.replyCount == 0
        }
    }
}
