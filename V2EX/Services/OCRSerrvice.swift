import Foundation

protocol OCRSerrvice {
    
    func recognize(
        picBase64: String,
        success: ((String) -> Void)?,
        failure: Failure?)
}

extension OCRSerrvice {
    
    private func accessToken(
        success: ((BaiduOauthToken?) -> Void)?,
        failure: Failure?) {
        
        Network.request(
            target: .baiduAccessToken(
                clientId: Constants.BaiduOCR.appKey,
                clientSecret: Constants.BaiduOCR.secretKey),
            success: { data in
                let oauthResult = BaiduOauthToken.oauthResult(data: data)
                success?(oauthResult)
        }, failure: failure)
    }
    
    func recognize(
        picBase64: String,
        success: ((String) -> Void)?,
        failure: Failure?) {
        
        accessToken(success: { oauthResult in
            guard let accessToken = oauthResult?.accessToken else {
                failure?("Oauth failed")
                return
            }
            
            Network.request(target: .baiduOCRRecognize(
                accessToken: accessToken,
                picBase64: picBase64), success: { data in
                    let response = BaiduOcrResponse.result(data: data)
                    log.info(response?.wordsResult)
                    if let captcha = response?.wordsResult?.first?.words.trimmed, captcha.count == 8 {
                        success?(captcha)
                    } else {
                        failure?("recognize error")
                    }
            }, failure: failure)
            
        }, failure: failure)
    }
}
