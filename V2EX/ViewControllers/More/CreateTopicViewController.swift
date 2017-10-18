import UIKit
import IQKeyboardManagerSwift

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
    
    private lazy var bodyTextView: UIPlaceholderTextView = {
        let view = UIPlaceholderTextView()
        view.placeholder = "请输入正文，如果标题能够表达完整内容，则正文可以为空(0~20000)"
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 5)
        view.returnKeyType = .done
        view.font = UIFont.systemFont(ofSize: 15)
        view.keyboardDismissMode = .onDrag
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.sharedManager().enable = false
    }

    deinit {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func setupSubviews() {
        view.addSubviews(
            titleLabel,
            titleFieldView,
            bodyLabel,
            bodyTextView
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain) {
            log.info("Public Topic")
        }
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
}

