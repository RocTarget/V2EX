import Foundation
import UIKit
import YYText
import SnapKit

let KcommentInputViewHeight: CGFloat = 55

class CommentInputView: UIView {

     public lazy var textView: YYTextView = {
        let view = YYTextView()
        view.placeholderAttributedText = NSAttributedString(
            string: "添加一条新回复",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.6)])

//        view.placeholder = "添加一条新回复"  // 奔溃 。。。
        view.setCornerRadius = 17.5
        view.font = UIFont.systemFont(ofSize: 15)
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Color.borderColor.cgColor
        view.scrollsToTop = false
        view.textContainerInset = UIEdgeInsets(top: 8, left: 14, bottom: 5, right: 14)
        view.backgroundColor = Theme.Color.bgColor
        view.returnKeyType = .send
        view.enablesReturnKeyAutomatically = true
        view.delegate = self
        view.textParser = MentionedParser()
        view.tintColor = Theme.Color.globalColor
        self.addSubview(view)
        return view
    }()

    private lazy var uploadPictureBtn: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "uploadPicture"), for: .normal)
        view.setImage(#imageLiteral(resourceName: "uploadPicture"), for: .selected)
        self.addSubview(view)
        return view
    }()

    public var inputViewHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return KcommentInputViewHeight + safeAreaInsets.bottom
        } else {
            return KcommentInputViewHeight
        }
    }

    private struct Misc {
        static let maxLine = 5
        static let textViewContentHeight: CGFloat = KcommentInputViewHeight - 20
    }

    public var sendHandle: Action?
    public var atUserHandle: Action?
    public var uploadPictureHandle: Action?
    public var updateHeightHandle: ((CGFloat) -> Void)?

    private var uploadPictureRightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {

        backgroundColor = .white
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.left.equalToSuperview().inset(15)
            $0.right.equalTo(uploadPictureBtn.snp.left).inset(-15)

            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(10)
            } else {
                $0.bottom.equalToSuperview().inset(10)
            }
        }

        uploadPictureBtn.snp.makeConstraints {
            uploadPictureRightConstraint = $0.left.equalTo(snp.right).constraint
            $0.centerY.equalTo(textView)
            $0.width.equalTo(32)
        }

        uploadPictureBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.uploadPictureHandle?()
        }.disposed(by: rx.disposeBag)

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.backgroundColor = theme.whiteColor
                self?.borderTop = Border(size: 1,color: theme == .day ? theme.borderColor : UIColor.hex(0x19171A))
                self?.textView.backgroundColor = theme == .day ? theme.bgColor : UIColor.hex(0x101014)
                self?.textView.layer.borderColor = (theme == .day ? theme.borderColor : UIColor.hex(0x19171A)).cgColor
                self?.textView.keyboardAppearance = theme == .day ? .default : .dark
            }.disposed(by: rx.disposeBag)
    }

}

extension CommentInputView: YYTextViewDelegate {

    func textViewDidBeginEditing(_ textView: YYTextView) {
        UIView.animate(withDuration: 1) {
            self.uploadPictureRightConstraint?.update(offset: -50)
            self.uploadPictureBtn.layoutIfNeeded()
        }
    }

    func textViewDidEndEditing(_ textView: YYTextView) {
        uploadPictureRightConstraint?.update(offset: 0)
    }

    func textView(_ textView: YYTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendHandle?()
            textView.resignFirstResponder()
            return false
        }

        if text == "@" {
            GCD.delay(0.2, block: {
                self.atUserHandle?()
            })
        }
        return true
    }

    func textViewDidChange(_ textView: YYTextView) {

        guard let lineHeight = textView.font?.lineHeight else { return }

        // 调用代理方法
        let contentHeight = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom)
        let rows =  Int(contentHeight / lineHeight)

        guard rows <= Misc.maxLine else { return }

        var height = Misc.textViewContentHeight * rows.f
        height = height < inputViewHeight ? inputViewHeight : height

        log.info("height = ", height)
        self.updateHeightHandle?(height)
    }
}
