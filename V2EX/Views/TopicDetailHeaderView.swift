import UIKit
import WebKit
import SnapKit

class TopicDetailHeaderView: UIView{
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.hex(0xA3A3A3)
        return view
    }()
    
    private lazy var nodeLabel: UIInsetLabel = {
        let view = UIInsetLabel()
        view.font = UIFont.systemFont(ofSize: 13)
        view.textColor = UIColor.hex(0x999999)
        view.backgroundColor = Theme.Color.bgColor
        view.contentInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.boldSystemFont(ofSize: 17)
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.scrollView.isScrollEnabled = false
//        view.scrollView.delaysContentTouches = false
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        return view
    }()

    private var webViewConstraint: Constraint?

    public var webLoadComplete: Action?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 130))
        backgroundColor = .white

        addSubviews(
            avatarView,
            usernameLabel,
            timeLabel,
            nodeLabel,
            titleLabel,
            webView
        )
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        avatarView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.top.equalTo(avatarView).offset(3)
        }
        
        timeLabel.snp.makeConstraints {
            $0.left.equalTo(usernameLabel)
            $0.right.equalTo(nodeLabel).priority(.high)
            $0.bottom.equalTo(avatarView).inset(3)
        }
        
        nodeLabel.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(15)
        }
        
        titleLabel.snp.makeConstraints {
            $0.right.equalTo(timeLabel)
            $0.left.equalTo(avatarView)
            $0.top.equalTo(avatarView.snp.bottom).offset(15)
        }

        webView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            webViewConstraint = $0.height.equalTo(0).constraint
        }
    }
    
    var topic: TopicModel? {
        didSet {
            guard let `topic` = topic else { return }
            
            avatarView.setRoundImage(urlString: topic.user.avatarSrc)
            usernameLabel.text = topic.user.name
            titleLabel.text = topic.title
            timeLabel.text = [topic.publicTime, topic.clickCount].joined(separator: " · ")
            timeLabel.isHidden = topic.publicTime.isEmpty
            
            do {
                let cssString = try String(contentsOf: R.file.styleCss()!)
                let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(cssString)</style></head>"
                let body = "<body><div id=\"Wrapper\">\(topic.content)</div></body>"
                let html = "<html>\(head)\(body)</html>"
                webView.loadHTMLString(html, baseURL: URL(string: "https://"))
            } catch {
                log.error("CSS 加载失败")
            }
            
            guard let node = topic.node else { return }
            nodeLabel.text = node.name
        }
    }
}

extension TopicDetailHeaderView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
            guard let htmlHeight = result as? CGFloat else { return }

//            webView.frame = CGRect(x: 0, y: self.titleLabel.bottom, width: self.width, height: htmlHeight)
            log.debug(htmlHeight)
            self.webViewConstraint?.update(offset: htmlHeight)
            self.height = self.titleLabel.bottom + htmlHeight + 15
            self.webLoadComplete?()
        }
    }
}
