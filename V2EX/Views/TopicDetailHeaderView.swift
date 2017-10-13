import UIKit
import WebKit

class TopicDetailHeaderView: UIView{
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
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

//    private lazy var webView: UIWebView = {
//        let view = UIWebView()
////        view.scrollView.isScrollEnabled = false
////        view.scrollView.delaysContentTouches = false
////        view.translatesAutoresizingMaskIntoConstraints = false
////        view.navigationDelegate = self
//        view.delegate = self
//        return view
//    }()

    public var webLoadComplete: Action?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.screenWidth, height: 130))
        
        addSubviews(
            avatarView,
            usernameLabel,
            timeLabel,
            nodeLabel,
            titleLabel,
            webView
        )
        
        setupConstraints()

        webView.scrollView.rx.observe(CGSize.self, "contentSize").subscribeNext { size in
            log.info(size)
        }.disposed(by: rx.disposeBag)
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
    }
    
    var topic: TopicModel? {
        didSet {
            guard let `topic` = topic else { return }
            
            avatarView.setRoundImage(urlString: topic.user.avatarSrc)
            usernameLabel.text = topic.user.name
            nodeLabel.text = topic.node.name
            titleLabel.text = topic.title
            timeLabel.text = [topic.publicTime, topic.clickCount].joined(separator: " · ")
            
            do {
                let cssString = try String(contentsOf: R.file.styleCss()!)
                let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(cssString)</style></head>"
                let body = "<body><div id=\"Wrapper\">\(topic.content)</div></body>"
                let html = "<html>\(head)\(body)</html>"
                webView.loadHTMLString(html, baseURL: URL(string: Config.baseURL))
            } catch {
                log.error("CSS 加载失败")
            }
        }
    }
}


extension TopicDetailHeaderView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
            guard let htmlHeight = result as? CGFloat else { return }
            
            log.info("web height = ", htmlHeight, "view height =", self.height, webView.scrollView.contentSize)
            
            webView.frame = CGRect(x: 0, y: self.titleLabel.bottom, width: self.width, height: htmlHeight)
            self.height += webView.height
            self.webLoadComplete?()
        }
    }
}