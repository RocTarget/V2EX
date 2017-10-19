import UIKit
import Marklight
import RxSwift
import RxCocoa

class CreateTopicViewController: BaseViewController {
    
    // MARK: Constants
//
//    fileprivate struct Limit {
//        static let maxCharacter = 20000
//    }
//
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

    let textContainer = NSTextContainer()

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
        textStorage.marklightTextProcessor.hideSyntax = true
        return textStorage
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
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

        NotificationCenter.default.addObserver(forName: .UITextViewTextDidChange, object: textView, queue: OperationQueue.main) { (notification) -> Void in
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


        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "发布", style: .plain) {
                log.info("Public Topic")
            },
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
        ]
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

    }
}


// MARK: - Character limit
extension CreateTopicViewController: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        guard  let currentText = textView.text,
//            let stringRange = range.range(for: currentText) else { return false }
//
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
//
//        let isInBound = updatedText.length <= Limit.maxCharacter
//        if isInBound {
//            descriptionNumLabel.text = "\(updatedText.length)/\(Limit.maxCharacter)"
//        }
//        return isInBound
//    }


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

