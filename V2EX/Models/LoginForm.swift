import Foundation

struct LoginForm {
    var usernameKey: String
    var passwordKey: String
    var captchaKey: String
    var captchaImageData: Data
    var once: String
    
    var username: String
    var password: String
    var captcha: String
    
    func loginDict() -> [String: String] {
        return [
            usernameKey: username,
            passwordKey: password,
            captchaKey: "",
            "once": once,
            "next": "/"
        ]
    }
}
