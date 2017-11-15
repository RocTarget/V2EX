import UIKit

class AdjustFontViewController: BaseViewController {

    private lazy var previewContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var avatarView: UIImageView = {
        return UIImageView(image: #imageLiteral(resourceName: "avatarRect"))
    }()

    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        view.text = "Joe"
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "如果调节主题详情内容的字体大小？"
        view.numberOfLines = 0
        view.font = UIFont.boldSystemFont(ofSize: 17)
        return view
    }()

    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.text = "试试滑动下方的滑块来调节字体大小。"
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: CGFloat(sliderView.value) * 15.f)
        return view
    }()

    private lazy var sliderContainerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Theme.Color.borderColor.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()

    private lazy var sliderView: UISlider = {
        let view = UISlider()
        view.minimumValue = 1.0
        view.maximumValue = 2.0
        view.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        view.tintColor = Theme.Color.globalColor
        view.value = (UserDefaults.get(forKey: Constants.Keys.webViewFontScale) as? Float) ?? 1.0
        return view
    }()

    private lazy var minLabel: UILabel = {
        let view = UILabel()
        view.text = "小"
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()

    private lazy var maxLabel: UILabel = {
        let view = UILabel()
        view.text = "大"
        view.font = UIFont.systemFont(ofSize: 30)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "阅读设置"
        view.backgroundColor = .white

        ThemeStyle.style
            .asObservable()
            .subscribeNext { [weak self] theme in
                self?.view.backgroundColor = theme.whiteColor
                self?.titleLabel.textColor = theme.titleColor
                self?.usernameLabel.textColor = theme.titleColor
                self?.contentLabel.textColor = theme.titleColor
                self?.sliderContainerView.layer.borderColor = theme.borderColor.cgColor
                self?.minLabel.textColor = theme.titleColor
                self?.maxLabel.textColor = theme.titleColor
            }.disposed(by: rx.disposeBag)
    }

    override func setupSubviews() {
        view.addSubviews(previewContainerView, sliderContainerView)
        previewContainerView.addSubviews(avatarView, usernameLabel, titleLabel, contentLabel)
        sliderContainerView.addSubviews(sliderView, minLabel, maxLabel)
    }

    override func setupConstraints() {

        // MARK - Preview ContainerView
        previewContainerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(200)
            $0.top.equalToSuperview().offset(120)
        }

        avatarView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(48)
        }

        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.centerY.equalTo(avatarView)
        }

        titleLabel.snp.makeConstraints {
            $0.right.equalToSuperview().inset(15)
            $0.left.equalTo(avatarView)
            $0.top.equalTo(avatarView.snp.bottom).offset(15)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.left.right.equalTo(titleLabel)
        }

        // MARK : - Slider ContainerView
        sliderContainerView.snp.makeConstraints {
            $0.top.equalTo(previewContainerView.snp.bottom).offset(80)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(sliderView)
        }

        sliderView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.65)
            $0.height.equalTo(60)
        }

        minLabel.snp.makeConstraints {
            $0.right.equalTo(sliderView.snp.left).inset(-20)
            $0.centerY.equalTo(sliderView)
        }

        maxLabel.snp.makeConstraints {
            $0.left.equalTo(sliderView.snp.right).offset(20)
            $0.centerY.equalTo(minLabel)
        }
    }

    @objc func sliderValueDidChange() {
        contentLabel.font = UIFont.systemFont(ofSize: CGFloat(sliderView.value) * 15.f)

        UserDefaults.save(at: sliderView.value, forKey: Constants.Keys.webViewFontScale)
    }
}
