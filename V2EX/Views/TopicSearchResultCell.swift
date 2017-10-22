import UIKit

class TopicSearchResultCell: BaseTableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = UIColor.hex(0x606060)
        view.font = UIFont.boldSystemFont(ofSize: 17)
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 5
        view.textColor = UIColor.hex(0xD7D5D7)
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var desLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.hex(0xDEDEDE)
        view.font = UIFont.systemFont(ofSize: 11)
        return view
    }()
    
    public var query: String?
    
    public var topic: SearchTopicModel? {
        didSet {
            guard let `topic` = topic else { return }
            titleLabel.text = topic.title
            
            contentLabel.text = topic.content?
                .deleteOccurrences(target: "\r")
                .deleteOccurrences(target: "\n")
            
            if let `query` = query {
                titleLabel.highlight(text: query, normal: nil, highlight: [NSAttributedStringKey.foregroundColor : UIColor.hex(0xD33F3F)])
                contentLabel.highlight(text: query, normal: nil, highlight: [NSAttributedStringKey.foregroundColor : UIColor.hex(0xD33F3F)])
            }
            guard let memberName = topic.member,
                let time = topic.created,
                let replies = topic.replies else { return }
            
            desLabel.text = "\(memberName) 于 \(time) 发表, 共计 \(replies) 个回复"
            desLabel.makeSubstringColor(memberName, color: Theme.Color.linkColor)
        }
    }
    
    override func initialize() {
        selectionStyle = .none
        separatorInset = .zero
        
        contentView.addSubviews(
            titleLabel,
            contentLabel,
            desLabel
        )
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview().inset(15)
        }
        
        contentLabel.snp.makeConstraints {
            $0.left.right.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        desLabel.snp.makeConstraints {
            $0.left.right.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(15)
            $0.top.equalTo(contentLabel.snp.bottom).offset(10)
        }
    }
}
