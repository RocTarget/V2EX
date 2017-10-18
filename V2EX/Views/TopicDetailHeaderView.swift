import UIKit
import WebKit
import SnapKit

enum TapType {
    case user(MemberModel)
    case node(NodeModel)
    case image(String)
    case webpage(URL)
    case topic(String)
}

class TopicDetailHeaderView: UIView{
    
    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
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
        view.isUserInteractionEnabled = true
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

    public var tapHandle: ((_ type: TapType) -> Void)?
    
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
        setupAction()
    }

    func setupAction() {
        let avatarTapGesture = UITapGestureRecognizer()
        avatarView.addGestureRecognizer(avatarTapGesture)

        let nodeTapGesture = UITapGestureRecognizer()
        nodeLabel.addGestureRecognizer(nodeTapGesture)

        avatarTapGesture.rx
            .event
            .subscribeNext { [weak self] _ in
                guard let user = self?.topic?.user else {
                    return
                }
                self?.tapHandle?(.user(user))
            }.disposed(by: rx.disposeBag)

        nodeTapGesture.rx
            .event
            .subscribeNext { [weak self] _ in
                guard let node = self?.topic?.node else {
                    return
                }
                self?.tapHandle?(.node(node))
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
            usernameLabel.text = topic.user.username
            titleLabel.text = topic.title
            timeLabel.text = topic.publicTime
            timeLabel.isHidden = topic.publicTime.isEmpty
            
            do {
                if let filePath = Bundle.main.path(forResource: "style", ofType: "css") {
                    let cssString = try String(contentsOfFile: filePath)
                    let head = "<head><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"><style>\(cssString)</style></head>"
                    let body = "<body><div id=\"Wrapper\">\(topic.content)</div></body>"
                    let html = "<html>\(head)\(body)</html>"
                    webView.loadHTMLString(html, baseURL: URL(string: "https://"))
                }
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

            self.webViewConstraint?.update(offset: htmlHeight)
            self.height = self.titleLabel.bottom + htmlHeight + 15
            self.webLoadComplete?()
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if url.scheme == "v2ex-image" {
                let src = urlString.replacingOccurrences(of: "v2ex-image:", with: "")
                tapHandle?(.image(src))
                decisionHandler(.cancel)
                return
            }else if urlString.hasPrefix("https://") || urlString.hasPrefix("http://") {
                if navigationAction.navigationType == .linkActivated {
                    let isTopic = url.deletingLastPathComponent().absoluteString == Constants.Config.baseURL + "/t/"
                    if isTopic {
                        tapHandle?(.topic(url.lastPathComponent))
                    } else {
                        tapHandle?(.webpage(url))
                    }
                    decisionHandler(.cancel)
                    return
                }
            } else if urlString.hasPrefix("/member/") {
                let href = url.path
                let name = href.lastPathComponent
                tapHandle?(.user(MemberModel(username: name, url: href, avatar: "")))
            } else if urlString.hasPrefix("/t/") {
                tapHandle?(.topic(url.lastPathComponent))
            } else if urlString.hasPrefix("/go/") {
                tapHandle?(.node(NodeModel(name: "", href: urlString)))
            }
        }
        decisionHandler(.allow)
    }
}
