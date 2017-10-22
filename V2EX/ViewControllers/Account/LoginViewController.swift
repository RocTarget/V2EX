import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController, AccountService {
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "site_logo"))
        return view
    }()
    
    private lazy var introLabel: UILabel = {
        let view = UILabel()
        view.text = "Way to explore"
        return view
    }()
    
    private lazy var accountTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入用户名或电子邮箱"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.keyboardType = .emailAddress
        view.delegate = self
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入密码"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.keyboardType = .asciiCapable
        view.isSecureTextEntry = true
        view.delegate = self
        return view
    }()
    
    private lazy var captchaTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入验证码"
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        //        view.setCornerRadius = 5
        view.textColor = Theme.Color.globalColor
        view.font = UIFont.systemFont(ofSize: 16)
        view.addLeftTextPadding(10)
        view.clearButtonMode = .whileEditing
        view.rightView = self.captchaBtn
        view.rightViewMode = .always
        view.keyboardType = .asciiCapable
        view.delegate = self
        view.returnKeyType = .go
        view.autocapitalizationType = .none
        return view
    }()
    
    private lazy var captchaBtn: LoadingButton = {
        let view = LoadingButton()
        view.size = CGSize(width: 150, height: 50)
        view.setTitle("重新加载验证码", for: .normal)
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

    private lazy var forgetBtn: UIButton = {
        let view = UIButton()
        view.setTitle("忘记密码?", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

    private lazy var registerBtn: UIButton = {
        let view = UIButton()
        view.setTitle("还没有账号? 点击立即注册", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

    private var loginForm: LoginForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func setupSubviews() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain) { [weak self] in
            self?.dismiss()
        }

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "bj"))

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)

        view.addSubviews(
            blurView,
            logoView,
            introLabel,
            accountTextField,
            passwordTextField,
            captchaTextField,
            loginBtn,
            registerBtn,
            forgetBtn
        )
    }
    
    override func setupConstraints() {
        logoView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(view.height * 0.2)
        }
        
        introLabel.snp.makeConstraints {
            $0.top.equalTo(logoView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        accountTextField.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(50)
            $0.top.equalToSuperview().offset(view.height * 0.4)
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

        forgetBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loginBtn.snp.bottom).offset(15)
        }

        registerBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(forgetBtn.snp.bottom).offset(10)
        }
    }
    
    override func setupRx() {

        // 获得焦点
        Observable.just(UserDefaults.get(forKey: Constants.Keys.loginAccount))
            .map { $0 as? String}
            .doOnNext({ [weak self] text in
                _ = text.isNilOrEmpty ?
                    self?.accountTextField.becomeFirstResponder() :
                    self?.passwordTextField.becomeFirstResponder()
            })
            .bind(to: accountTextField.rx.text)
            .disposed(by: rx.disposeBag)

        // 上次登录成功的账号名
        if let loginName = UserDefaults.get(forKey: Constants.Keys.loginAccount) as? String {
            accountTextField.text = loginName
            accountTextField.rx.value.onNext(loginName)
        }

        // 验证输入状态
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

        // 点击处理
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

        forgetBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
            }.disposed(by: rx.disposeBag)

        registerBtn.rx
            .tap
            .subscribeNext { [weak self] in
                // 暂时用网页代替
                let webView = SweetWebViewController(url: "https://www.v2ex.com/signup")
                self?.navigationController?.pushViewController(webView, animated: true)
//                self?.navigationController?.pushViewController(RegisterViewController(), animated: true)
            }.disposed(by: rx.disposeBag)
    }
    
    @objc func fetchCode() {
        captchaBtn.isLoading = true
        captchaBtn.setImage(UIImage(), for: .normal)

        captcha(type: .signin,
                success: { [weak self] loginForm in
                    self?.captchaBtn.setImage(UIImage(data: loginForm.captchaImageData), for: .normal)
                    self?.loginForm = loginForm
                    self?.captchaBtn.isLoading = false
        }) { [weak self] error in
            self?.captchaBtn.isLoading = false
            HUD.showText(error)
        }
    }
    
    func loginHandle() {
        view.endEditing(true)
        
        guard var form = loginForm else {
            HUD.showText("登录失败, 无法获取表单数据, 请尝试重启 App", delay: 1.5)
            return
        }
        
        guard let username = accountTextField.text?.trimmed, username.isNotEmpty else {
            HUD.showText("请正确输入用户名或邮箱", delay: 1.5)
            return
        }
        
        guard let password = passwordTextField.text?.trimmed, password.isNotEmpty else {
            HUD.showText("请输入用户名或邮箱密码", delay: 1.5)
            return
        }
        guard let captcha = captchaTextField.text?.trimmed, captcha.isNotEmpty else {
            HUD.showText("请输入验证码", delay: 1.5)
            return
        }
        
        HUD.show()
        
        form.username = username
        form.password = password
        form.captcha = captcha
        signin(loginForm: form, success: { [weak self] in
            HUD.dismiss()
            self?.dismiss()
        }) { [weak self] error, form in
            HUD.dismiss()
            HUD.showText(error)
            self?.captchaTextField.text = ""
            if let `form` = form {
                self?.captchaBtn.setImage(UIImage(data: form.captchaImageData), for: .normal)
                self?.loginForm = form
            }
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
