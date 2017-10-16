import Foundation

struct LoginForm {
    var usernameKey: String
    var passwordKey: String
    var emailKey: String
    var captchaKey: String
    var captchaImageData: Data
    var once: String


    var username: String = ""
    var password: String = ""
    var captcha: String = ""
    var email: String

    init(usernameKey: String, passwordKey: String = "", emailKey: String = "", captchaKey: String, captchaImageData: Data, once: String, email: String = "") {
        self.usernameKey = usernameKey
        self.passwordKey = passwordKey
        self.emailKey = emailKey
        self.captchaKey = captchaKey
        self.captchaImageData = captchaImageData
        self.once = once
        self.email = email
    }

    func loginDict() -> [String: String] {
        return [
            usernameKey: username,
            passwordKey: password,
            captchaKey: captcha,
            "once": once,
            "next": "/"
        ]
    }

    func forgotDict() -> [String: String] {
        return [
            usernameKey: username,
            emailKey: email,
            captchaKey: captcha,
            "once": once,
            "next": "/"
        ]
    }
}
