import Foundation
import UIKit


class CommentInputView: UIView {

    public var sendHandle: Action?

    private lazy var textView: UIPlaceholderTextView = {
        let view = UIPlaceholderTextView()
        view.placeholder = "添加一条新回复"
        view.setCornerRadius = 17.5
        view.font = UIFont.systemFont(ofSize: 15)
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Color.borderColor.cgColor
        view.layoutManager.allowsNonContiguousLayout = false
        view.scrollsToTop = false
        view.textContainerInset = UIEdgeInsets(top: view.textContainerInset.top, left: 14, bottom: 5, right: 14)
        view.backgroundColor = Theme.Color.bgColor
        view.returnKeyType = .send
        view.enablesReturnKeyAutomatically = true
        view.delegate = self
        self.addSubview(view)
        return view
    }()

    public var text: String {
        set {
            textView.text = newValue
        } get {
            return textView.text
        }
    }

    public func beFirstResponder() {
        guard !textView.isFirstResponder else { return }
        
        textView.becomeFirstResponder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        borderTop = Border(size: 1,color: Theme.Color.borderColor)
        backgroundColor = .white
        
        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.left.right.equalToSuperview().inset(15)
        }
    }
}

extension CommentInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendHandle?()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
