import Foundation
import UIKit


class CommentInputView: UIView {

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
        return view
    }()

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

        addSubview(textView)

        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.left.right.equalToSuperview().inset(15)
        }
    }
}
