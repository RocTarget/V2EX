import UIKit
import Marklight
import RxSwift
import RxCocoa

class CreateTopicViewController: BaseViewController, TopicService {
    
    // MARK: Constants
    fileprivate struct Limit {
        static let titleMaxCharacter = 120
        static let bodyMaxCharacter = 20000
    }

    private lazy var titleLabel: UILabel = {
        let view = UIInsetLabel()
        view.text = "主题标题"
        view.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.textAlignment = .left
        view.backgroundColor = .white
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var titleFieldView: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入主题标题(0~120)"
        view.addLeftTextPadding(15)
        view.font = UIFont.systemFont(ofSize: 15)
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var bodyLabel: UIInsetLabel = {
        let view = UIInsetLabel()
        view.text = "正文"
        view.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.textAlignment = .left
        view.backgroundColor = .white
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

//    var bodyTextView : UIPlaceholderTextView?

    private lazy var bodyTextView: UIPlaceholderTextView = {
        let textContainer = NSTextContainer()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        let view = UIPlaceholderTextView(frame: .zero, textContainer: textContainer)
        view.placeholder = "请输入正文，如果标题能够表达完整内容，则正文可以为空(0~20000)"
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 5)
        view.returnKeyType = .done
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 15)
        view.keyboardDismissMode = .onDrag
        view.delegate = self
        view.isEditable = true
        return view
    }()

//    private var bodyText: String = ""

    private lazy var textStorage: MarklightTextStorage = {
        let textStorage = MarklightTextStorage()
        textStorage.marklightTextProcessor.codeColor = .orange
        textStorage.marklightTextProcessor.quoteColor = .darkGray
        textStorage.marklightTextProcessor.syntaxColor = .blue
        textStorage.marklightTextProcessor.codeFontName = "Courier"
        textStorage.marklightTextProcessor.fontTextStyle = UIFontTextStyle.subheadline.rawValue
//        textStorage.marklightTextProcessor.hideSyntax = true
        return textStorage
    }()
    
    private lazy var postTopicBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "发布")
        return view
    }()

    private lazy var previewBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "预览")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        titleFieldView.becomeFirstResponder()

        /// 恢复草稿
        if let title = UserDefaults.get(forKey: Constants.Keys.createTopicTitleDraft) as? String {
            titleFieldView.text = title
            titleFieldView.rx.value.onNext(title)
        }

        if let body = UserDefaults.get(forKey: Constants.Keys.createTopicBodyDraft) as? String {
            bodyTextView.text = body
            bodyTextView.rx.value.onNext(body)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UserDefaults.save(at: titleFieldView.text, forKey: Constants.Keys.createTopicTitleDraft)
        UserDefaults.save(at: bodyTextView.text, forKey: Constants.Keys.createTopicBodyDraft)
//        if let titleString = titleFieldView.text, titleString.trimmed.isNotEmpty {
//            UserDefaults.save(at: titleString, forKey: Constants.Keys.createTopicTitleDraft)
//        }
//
//        if let bodyString = bodyTextView.text, bodyString.trimmed.isNotEmpty {
//            UserDefaults.save(at: bodyString, forKey: Constants.Keys.createTopicBodyDraft)
//        }
    }

    override func setupSubviews() {

        // Load a sample markdown content from a file inside the app bundle
        //        if let samplePath = Bundle.main.path(forResource: "Sample", ofType:  "md"){
        //            do {
        //                let string = try String(contentsOfFile: samplePath)
        //                // Convert string to an `NSAttributedString`
        //                let attributedString = NSAttributedString(string: string)
        //
        //                // Set the loaded string to the `UITextView`
        //                textStorage.append(attributedString)
        //            } catch _ {
        //                print("Cannot read Sample.md file")
        //            }
        //        }

        NotificationCenter.default.addObserver(forName: .UITextViewTextDidChange, object: textView, queue: .main) { notification in
            if self.bodyTextView.textStorage.string.hasSuffix("\n") {
                CATransaction.setCompletionBlock({ () -> Void in
                    self.scrollToCaret(self.bodyTextView, animated: false)
                })
            } else {
                self.scrollToCaret(self.bodyTextView, animated: false)
            }
        }

        view.addSubviews(
            titleLabel,
            titleFieldView,
            bodyLabel,
            bodyTextView
        )
        
        //            UIBarButtonItem(title: "预览", style: .plain) { [weak self] in
        //                guard let `self` = self else { return }
        //
        //
        //
        //                if self.bodyTextView.tag.boolValue { // plain text
        //                    self.bodyText = self.bodyTextView.text
        //                    let attributedString = NSAttributedString(string: self.bodyText)
        //                    self.bodyTextView.attributedText = attributedString
        //                } else { // attr text
        //                    self.bodyTextView.text = self.bodyText
        //                    self.bodyTextView.font = UIFont.systemFont(ofSize: 15)
        //                    self.bodyTextView.textColor = .black
        //                }
        //                self.bodyTextView.tag = (!self.bodyTextView.tag.boolValue).intValue
        //            }
        navigationItem.rightBarButtonItems = [postTopicBarButton, previewBarButton]
    }

    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        titleFieldView.snp.makeConstraints {
            $0.left.right.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(1)
            $0.height.equalTo(50)
        }
        
        bodyLabel.snp.makeConstraints {
            $0.left.right.height.equalTo(titleLabel)
            $0.top.equalTo(titleFieldView.snp.bottom).offset(1)
        }
        
        bodyTextView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(bodyLabel.snp.bottom).offset(1)
        }
    }

    override func setupRx() {
        
        // 验证输入状态
        titleFieldView.rx
            .text
            .orEmpty
            .flatMapLatest {
                return Observable.just( $0.trimmed.isNotEmpty && $0.trimmed.count <= Limit.titleMaxCharacter )
            }.bind(to: postTopicBarButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        bodyTextView.rx
            .text
            .orEmpty
            .map { $0.trimmed.isNotEmpty }
            .bind(to: previewBarButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        postTopicBarButton.rx
            .tap
            .subscribeNext { [weak self] in
                self?.postTopicHandle()
        }.disposed(by: rx.disposeBag)

        previewBarButton.rx
            .tap
            .subscribeNext { [weak self] in
                guard let markdownString = self?.bodyTextView.text else {
                    HUD.showText("预览失败，无法读取到正文内容")
                    return
                }
                let previewVC = MarkdownPreviewViewController(markdownString: markdownString)
                let nav = NavigationViewController(rootViewController: previewVC)
                self?.present(nav, animated: true, completion: nil)
            }.disposed(by: rx.disposeBag)
    }
    
    func postTopicHandle() {

        guard bodyTextView.text.count <= Limit.bodyMaxCharacter else {
            HUD.showText("正文内容不能超过 \(Limit.bodyMaxCharacter) 个字符")
            return
        }
        guard let title = titleFieldView.text else {
            HUD.showText("标题不能为空")
            return
        }
        
        createTopic(nodename: "sandbox", title: title, body: bodyTextView.text, success: { [weak self] in
            HUD.showText("发布成功")
            self?.titleFieldView.text = nil
            self?.bodyTextView.text = nil
            UserDefaults.remove(forKey: Constants.Keys.createTopicTitleDraft)
            UserDefaults.remove(forKey: Constants.Keys.createTopicBodyDraft)
        }) { error in
            HUD.showText(error)
        }
    }
}


// MARK: - Character limit
extension CreateTopicViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("Should interact with: \(URL)")
        return true
    }

    func scrollToCaret(_ textView: UITextView, animated: Bool) {
        var rect = textView.caretRect(for: textView.selectedTextRange!.end)
        rect.size.height = rect.size.height + textView.textContainerInset.bottom
        textView.scrollRectToVisible(rect, animated: animated)
    }
}
