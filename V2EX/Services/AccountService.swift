import Foundation

protocol AccountService {
    func captcha(
        success: ((LoginForm) -> Void)?,
        failure: Failure?)
    
    func signin(
        loginForm: LoginForm,
        success: ((String) -> Void)?,
        failure: Failure?)
}

extension AccountService {
    func captcha(
        success: ((LoginForm) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .captcha, success: { html in
            guard let usernameKey = html.xpath("//*[@id='Main']//div[@class='cell']/form/table/tr[1]/td[2]/input[@class='sl']").first?["name"],
                let passwordKey = html.xpath("//*[@id='Main']//div[@class='cell']/form/table/tr[2]/td[2]/input[@class='sl']").first?["name"],
                let captchaKey = html.xpath("//*[@id='Main']//div[@class='cell']/form/table/tr[3]/td[2]/input[@class='sl']").first?["name"],
                let once = html.xpath("//*[@name='once'][1]").first?["value"] else {
                    failure?("数据解析失败")
                    return
            }
            
            Network.request(target: .captchaImageData(once: once), success: { data in
                let loginForm = LoginForm(usernameKey: usernameKey, passwordKey: passwordKey, captchaKey: captchaKey, captchaImageData: data, once: once, username: "", password: "", captcha: "")
                success?(loginForm)
            }, failure: failure)
            
        }, failure: failure)
    }
    
    func signin(
        loginForm: LoginForm,
        success: ((String) -> Void)?,
        failure: Failure?) {
        Network.htmlRequest(target: .signin, success: { html in
            
            
        }, failure: failure)
    }
}
