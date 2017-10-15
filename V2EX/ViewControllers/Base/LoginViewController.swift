import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController, AccountService {
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView(image: Asset.site_logo())
        return view
    }()
    
    private lazy var introLabel: UILabel = {
        let view = UILabel()
        view.text = "Way to explore"
        return view
    }()
    
    private lazy var accountTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "用户名或电子邮箱"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.keyboardType = .emailAddress
        view.delegate = self
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "密码"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.keyboardType = .namePhonePad
        view.isSecureTextEntry = true
        view.delegate = self
        return view
    }()
    
    private lazy var captchaTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入图中的验证码"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.rightView = self.captchaBtn
        view.rightViewMode = .always
        view.keyboardType = .namePhonePad
        view.delegate = self
        view.returnKeyType = .go
        return view
    }()
    
    private lazy var captchaBtn: UIButton = {
        let view = UIButton()
        //        view.showsTouchWhenHighlighted = false
        //        view.adjustsImageWhenHighlighted = false
        view.size = CGSize(width: 150, height: 50)
        view.setTitle("点击加载验证码", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.setTitleColor(Theme.Color.globalColor, for: .normal)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return view
    }()
    
    private lazy var loginBtn: UIButton = {
        let view = UIButton()
        view.setTitle("登录", for: .normal)
        view.backgroundColor = Theme.Color.globalColor
        //        view.setCornerRadius = 5
        return view
    }()
    
    private var loginForm: LoginForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCode()
    }
    
    override func setupSubviews() {
        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        let blurView = UIVisualEffectView(effect: blurEffect)
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        self.view.addSubview(blurView)
        
        view.backgroundColor = UIColor(patternImage: Asset.bj1()!)
        view.addSubviews(
            logoView,
            introLabel,
            accountTextField,
            passwordTextField,
            captchaTextField,
            loginBtn
        )
    }
    
    override func setupConstraints() {
        logoView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(UIScreen.screenHeight * 0.2)
        }
        
        introLabel.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        accountTextField.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(50)
            $0.top.equalToSuperview().offset(UIScreen.screenHeight * 0.4)
            //            $0.top.equalTo(introLabel.snp.bottom).offset(120)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.left.right.height.equalTo(accountTextField)
            $0.top.equalTo(accountTextField.snp.bottom).offset(20)
        }
        
        captchaTextField.snp.makeConstraints {
            $0.left.right.height.equalTo(accountTextField)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
        }
        
        loginBtn.snp.makeConstraints {
            $0.left.right.height.equalTo(accountTextField)
            $0.top.equalTo(captchaTextField.snp.bottom).offset(30)
        }
    }
    
    override func setupRx() {
        
        let accountTextFieldUsable = accountTextField.rx
            .text
            .orEmpty
            .flatMapLatest {
                return Observable.just( $0.isNotEmpty )
        }
        
        let passwordTextFieldUsable = passwordTextField.rx
            .text
            .orEmpty
            .flatMapLatest {
                return Observable.just( $0.isNotEmpty )
        }
        
        let captchaTextFieldUsable = captchaTextField.rx
            .text
            .orEmpty
            .flatMapLatest {
                return Observable.just( $0.isNotEmpty )
        }
        
        Observable.combineLatest(
            accountTextFieldUsable,
            passwordTextFieldUsable,
            captchaTextFieldUsable) { $0 && $1 && $2}
            .distinctUntilChanged()
            .share(replay: 1)
            .bind(to: loginBtn.rx.isEnableAlpha)
            .disposed(by: rx.disposeBag)
        
        loginBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.loginHandle()
            }.disposed(by: rx.disposeBag)
        
        captchaBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.fetchCode()
            }.disposed(by: rx.disposeBag)
    }
    
    @objc func fetchCode() {
        
        captcha(success: { [weak self] loginForm in
            self?.captchaBtn.setImage(UIImage(data: loginForm.captchaImageData), for: .normal)
            self?.loginForm = loginForm
        }) { error in
            HUD.showText(error)
        }
    }
    
    func loginHandle() {
        view.endEditing(true)
        
        guard var form = loginForm else {
            HUD.showText("登录失败, 无法获取表单数据, 请尝试重启 App", delay: 1.5)
            return
        }
        
        guard let username = accountTextField.text, username.isNotEmpty else {
            HUD.showText("请正确输入用户名或邮箱", delay: 1.5)
            return
        }
        
        guard let password = passwordTextField.text, password.isNotEmpty else {
            HUD.showText("请输入用户名或邮箱密码", delay: 1.5)
            return
        }
        guard let captcha = captchaTextField.text, captcha.isNotEmpty else {
            HUD.showText("请输入验证码", delay: 1.5)
            return
        }
        
        HUD.show()
        
        form.username = username
        form.password = password
        form.captcha = captcha
        signin(loginForm: form, success: { d in
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        switch textField {
        case accountTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            captchaTextField.becomeFirstResponder()
        default:
            loginHandle()
            return true
        }

        return false
    }
}
