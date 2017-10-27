import UIKit
import YYText
import RxSwift
import RxCocoa
import MobileCoreServices

class ReplyMessageViewController: BaseViewController, TopicService {

    private lazy var contentView: UIView = {
        let view = UIView()
//        view.setCornerRadius = 15
        return view
    }()

    private lazy var topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xF1F2F1)
        return view
    }()

    private lazy var closeBtn: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = "回复"
        return view
    }()

    private lazy var uploadPictureBtn: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "uploadPicture"), for: .normal)
        return view
    }()

    private lazy var sendBtn: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        return view
    }()

    lazy var textView: YYTextView = {
        let view = YYTextView()
        view.font = UIFont.systemFont(ofSize: 15)
        view.textContainerInset = UIEdgeInsets(top: 8, left: 14, bottom: 5, right: 14)
        view.enablesReturnKeyAutomatically = true
        view.textParser = MentionedParser()
        view.tintColor = Theme.Color.globalColor
        view.backgroundColor = .white
        view.delegate = self
        return view
    }()

    private lazy var imagePicker: UIImagePickerController = {
        let view = UIImagePickerController()
        view.allowsEditing = true
        view.mediaTypes = [kUTTypeImage as String]
        view.sourceType = .photoLibrary
        view.delegate = self
        return view
    }()

    public var message: MessageModel? {
        didSet {
            guard let atUsername = message?.member?.atUsername else { return }
            textView.text = atUsername
            textView.becomeFirstResponder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true
    }

    override func setupRx() {
        closeBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.textView.resignFirstResponder()
        }.disposed(by: rx.disposeBag)

        uploadPictureBtn.rx
            .tap 
            .subscribeNext { [weak self] in
                guard let `self` = self else { return }
                self.present(self.imagePicker, animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)

        sendBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.replyComment()
        }.disposed(by: rx.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard view.isHidden else { return }
        textView.becomeFirstResponder()
    }

    override func setupSubviews() {
        view.backgroundColor = .clear

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 20
        contentView.layer.shadowOpacity = 0.8
        contentView.layer.shadowOffset = CGSize(width: 10, height: 10)

        view.addSubview(contentView)
        contentView.addSubviews(topContainer, textView)
        topContainer.addSubviews(closeBtn, titleLabel, uploadPictureBtn, sendBtn)
    }

    override func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.4)
            $0.top.equalToSuperview().offset(64)
        }

        topContainer.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(44)
        }

        closeBtn.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(topContainer.snp.height)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }

        sendBtn.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalToSuperview().inset(5)
            $0.width.equalTo(closeBtn)
        }

        uploadPictureBtn.snp.makeConstraints {
            $0.top.bottom.width.equalTo(sendBtn)
            $0.right.equalTo(sendBtn.snp.left)
        }

        textView.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom)
            $0.left.bottom.right.equalToSuperview()
        }
    }

    // 上传配图请求
    private func uploadPictureHandle(_ fileURL: String) {
        HUD.show()
        uploadPicture(localURL: fileURL, success: { [weak self] url in
            log.info(url)
            self?.textView.text.append(url)
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }

    /// 回复评论
    private func replyComment() {

        guard let `message` = message else { return }

        guard textView.text.trimmed.isNotEmpty else {
            HUD.showText("回复失败，您还没有输入任何内容", completionBlock: { [weak self] in
                self?.textView.becomeFirstResponder()
            })
            return
        }

        guard let once = message.once else {
            HUD.showText("无法获取 once，请尝试重新登录", completionBlock: {
                presentLoginVC()
            })
            return
        }

        guard let topicID = message.topic.topicID else {
            HUD.showText("无法获取主题 ID")
            return
        }

        HUD.show()
        comment(
            once: once,
            topicID: topicID,
            content: textView.text, success: { [weak self] in
                HUD.showText("回复成功")
                HUD.dismiss()
                self?.view.endEditing(true)
                self?.view.fadeOut()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }
}

extension ReplyMessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        guard var image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        image = image.resized(by: 0.7)
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }

        let path = FileManager.document.appendingPathComponent("smfile.png")
        _ = FileManager.save(data, savePath: path)
        uploadPictureHandle(path)
    }
}

extension ReplyMessageViewController: YYTextViewDelegate {

    func textViewDidEndEditing(_ textView: YYTextView) {
        view.fadeOut()
        view.isHidden = true
    }

    func textViewDidBeginEditing(_ textView: YYTextView) {
        view.isHidden = false
        view.fadeIn()
    }
}
