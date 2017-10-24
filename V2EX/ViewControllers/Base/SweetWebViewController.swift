import UIKit
import WebKit

let estimatedProgressKeyPath = "estimatedProgress"
let titleKeyPath = "title"

import Foundation

public enum BarButtonItemType {
    case back
    case forward
    case reload
    case stop
    case activity
    case done
    case flexibleSpace
}

public enum NavigationBarPosition {
    case none, left, right
}

@objc public enum NavigationType: Int {
    case linkActivated
    case formSubmitted
    case backForward
    case reload
    case formResubmitted
    case other
}


@objc public protocol SweetWebViewControllerDelegate {
    @objc optional func SweetWebViewController(_ controller: SweetWebViewController, canDismiss url: URL) -> Bool
    
    @objc optional func SweetWebViewController(_ controller: SweetWebViewController, didStart url: URL)
    @objc optional func SweetWebViewController(_ controller: SweetWebViewController, didFinish url: URL)
    @objc optional func SweetWebViewController(_ controller: SweetWebViewController, didFail url: URL, withError error: Error)
    @objc optional func SweetWebViewController(_ controller: SweetWebViewController, decidePolicy url: URL, navigationType: NavigationType) -> Bool
}

open class SweetWebViewController: UIViewController {

    open var url: URL?
    open var tintColor: UIColor?
    open var delegate: SweetWebViewControllerDelegate?
    open var bypassedSSLHosts: [String]?
    
    open var websiteTitleInNavigationBar = true
    open var doneBarButtonItemPosition: NavigationBarPosition = .left
    open var leftNavigaionBarItemTypes: [BarButtonItemType] = []
    open var rightNavigaionBarItemTypes: [BarButtonItemType] = []
    open var toolbarItemTypes: [BarButtonItemType] = [.back, .forward, .reload, .activity]
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isMultipleTouchEnabled = true
        return webView
    }()
    private var progressView: UIProgressView!
    
    private var previousNavigationBarState: (tintColor: UIColor, hidden: Bool) = (Theme.Color.globalColor, false)
    private var previousToolbarState: (tintColor: UIColor, hidden: Bool) = (.black, false)
    
    lazy private var backBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "backIcon"), style: .plain, target: self, action: #selector(backDidClick(sender:)))
    }()
    
    lazy private var forwardBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "forwardIcon"), style: .plain, target: self, action: #selector(forwardDidClick(sender:)))
    }()
    
    lazy private var reloadBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadDidClick(sender:)))
    }()
    
    lazy private var stopBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopDidClick(sender:)))
    }()
    
    lazy private var activityBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(activityDidClick(sender:)))
    }()
    
    lazy private var doneBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDidClick(sender:)))
    }()
    
    lazy private var flexibleSpaceBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()
    
    deinit {
        webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath)
        if websiteTitleInNavigationBar {
            webView.removeObserver(self, forKeyPath: titleKeyPath)
        }
        log.info("DEINIT: SweetWebViewController")
    }

    init(url: String) {
        self.url = URL(string: url)
        super.init(nibName: nil, bundle: nil)
    }

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {

        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: nil)
        if websiteTitleInNavigationBar {
            webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
        }
        
        view = webView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        UIBarButtonItem.appearance().tintColor = Theme.Color.globalColor

        // Do any additional setup after loading the view.
        navigationItem.title = navigationItem.title ?? url?.absoluteString
        
        if let navigationController = navigationController {
            previousNavigationBarState = (navigationController.navigationBar.tintColor, navigationController.navigationBar.isHidden)
            previousToolbarState = (navigationController.toolbar.tintColor, navigationController.toolbar.isHidden)
        }
        
        setUpProgressView()
        addBarButtonItems()
        
        if let url = url {
            load(url)
        }
        else {
            print("[SweetWebViewController][Error] Invalid url:", url as Any)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpState()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        rollbackState()
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case estimatedProgressKeyPath?:
            progressView.alpha = 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            
            if(webView.estimatedProgress >= 1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: {
                    finished in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        case titleKeyPath?:
            navigationItem.title = webView.title
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Public Methods
public extension SweetWebViewController {
    func load(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func load(_ html: String) {
        webView.loadHTMLString(html, baseURL: URL(string: "https://"))
    }
}

// MARK: - Fileprivate Methods
private extension SweetWebViewController {
    func setUpProgressView() {
        guard let navigationController = navigationController else {
            return
        }
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: navigationController.navigationBar.frame.size.height - progressView.frame.size.height, width: navigationController.navigationBar.frame.size.width, height: progressView.frame.size.height)
        progressView.trackTintColor = UIColor(white: 1, alpha: 0)
    }
    
    func addBarButtonItems() {
        let barButtonItems: [BarButtonItemType: UIBarButtonItem] = [
            .back: backBarButtonItem,
            .forward: forwardBarButtonItem,
            .reload: reloadBarButtonItem,
            .stop: stopBarButtonItem,
            .activity: activityBarButtonItem,
            .done: doneBarButtonItem,
            .flexibleSpace: flexibleSpaceBarButtonItem
        ]
        
        if presentingViewController != nil {
            switch doneBarButtonItemPosition {
            case .left:
                if !leftNavigaionBarItemTypes.contains(.done) {
                    leftNavigaionBarItemTypes.insert(.done, at: 0)
                }
            case .right:
                if !rightNavigaionBarItemTypes.contains(.done) {
                    rightNavigaionBarItemTypes.insert(.done, at: 0)
                }
            case .none:
                break
            }
        }
        
        navigationItem.leftBarButtonItems = leftNavigaionBarItemTypes.map {
            barButtonItemType in
            if let barButtonItem = barButtonItems[barButtonItemType] {
                return barButtonItem
            }
            return UIBarButtonItem()
        }
        
        navigationItem.rightBarButtonItems = rightNavigaionBarItemTypes.map {
            barButtonItemType in
            if let barButtonItem = barButtonItems[barButtonItemType] {
                return barButtonItem
            }
            return UIBarButtonItem()
        }
        
        if toolbarItemTypes.count > 0 {
            for index in 0..<toolbarItemTypes.count - 1 {
                toolbarItemTypes.insert(.flexibleSpace, at: 2 * index + 1)
            }
        }
        
        setToolbarItems(toolbarItemTypes.map {
            barButtonItemType -> UIBarButtonItem in
            if let barButtonItem = barButtonItems[barButtonItemType] {
                return barButtonItem
            }
            return UIBarButtonItem()
        }, animated: true)
    }
    
    func updateBarButtonItems() {
        backBarButtonItem.isEnabled = webView.canGoBack
        forwardBarButtonItem.isEnabled = webView.canGoForward
        
        let updateReloadBarButtonItem: (UIBarButtonItem, Bool) -> UIBarButtonItem = {
            [unowned self] barButtonItem, isLoading in
            switch barButtonItem {
            case self.reloadBarButtonItem:
                fallthrough
            case self.stopBarButtonItem:
                    return isLoading ? self.stopBarButtonItem : self.reloadBarButtonItem
            default:
                break
            }
            return barButtonItem
        }
        
        toolbarItems = toolbarItems?.map {
            [unowned self] barButtonItem -> UIBarButtonItem in
            return updateReloadBarButtonItem(barButtonItem, self.webView.isLoading)
        }
        
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems?.map {
            [unowned self] barButtonItem -> UIBarButtonItem in
            return updateReloadBarButtonItem(barButtonItem, self.webView.isLoading)
        }
        
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.map {
            [unowned self] barButtonItem -> UIBarButtonItem in
            return updateReloadBarButtonItem(barButtonItem, self.webView.isLoading)
        }
    }
    
    func setUpState() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(toolbarItemTypes.count == 0, animated: true)
    
        if let tintColor = tintColor {
            progressView.progressTintColor = tintColor
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.toolbar.tintColor = tintColor
        }
    
        navigationController?.navigationBar.addSubview(progressView)
    }
    
    func rollbackState() {
        progressView.removeFromSuperview()
    
        navigationController?.navigationBar.tintColor = previousNavigationBarState.tintColor
        navigationController?.toolbar.tintColor = previousToolbarState.tintColor
        
        navigationController?.setToolbarHidden(previousToolbarState.hidden, animated: true)
        navigationController?.setNavigationBarHidden(previousNavigationBarState.hidden, animated: true)
    }
    
    @objc func backDidClick(sender: AnyObject) {
        webView.goBack()
    }
    
    @objc func forwardDidClick(sender: AnyObject) {
        webView.goForward()
    }
    
    @objc func reloadDidClick(sender: AnyObject) {
        webView.stopLoading()
        if webView.url != nil {
            webView.reload()
        }
        else if let url = url {
            load(url)
        }
    }
    
    @objc func stopDidClick(sender: AnyObject) {
        webView.stopLoading()
    }
    
    @objc func activityDidClick(sender: AnyObject) {
        guard let url = url else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func doneDidClick(sender: AnyObject) {
        var canDismiss = true
        if let url = url {
            canDismiss = delegate?.SweetWebViewController?(self, canDismiss: url) ?? true
        }
        if canDismiss {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - WKUIDelegate
extension SweetWebViewController: WKUIDelegate {
    
}

// MARK: - WKNavigationDelegate
extension SweetWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateBarButtonItems()
        if let url = webView.url {
            self.url = url
            delegate?.SweetWebViewController?(self, didStart: url)
        }
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        updateBarButtonItems()
        if let url = webView.url {
            self.url = url
            delegate?.SweetWebViewController?(self, didFinish: url)
        }
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        log.error(error)
        updateBarButtonItems()
        if let url = webView.url {
            self.url = url
            delegate?.SweetWebViewController?(self, didFail: url, withError: error)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        log.error(error)
        updateBarButtonItems()
        if let url = webView.url {
            self.url = url
            delegate?.SweetWebViewController?(self, didFail: url, withError: error)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let bypassedSSLHosts = bypassedSSLHosts, bypassedSSLHosts.contains(challenge.protectionSpace.host) {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var actionPolicy: WKNavigationActionPolicy = .allow
        if let url = navigationAction.request.url, let navigationType = NavigationType(rawValue: navigationAction.navigationType.rawValue), let result = delegate?.SweetWebViewController?(self, decidePolicy: url, navigationType: navigationType) {
            actionPolicy = result ? .allow : .cancel
        }
        
        decisionHandler(actionPolicy)
    }
}
