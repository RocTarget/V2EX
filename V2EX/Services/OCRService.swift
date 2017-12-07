import Foundation

protocol OCRService {
    
    func recognize(
        imgBase64: String,
        success: ((String) -> Void)?,
        failure: Failure?)

    func recognize(
        imgURL: URL,
        success: ((String) -> Void)?,
        failure: Failure?)
}

extension OCRService {
    

    func recognize(
        imgBase64: String,
        success: ((String) -> Void)?,
        failure: Failure?) {

        accessToken(success: { oauthResult in
            guard let accessToken = oauthResult.accessToken else {
                failure?("Oauth failed")
                return
            }
            self.recognize(accessToken: accessToken, imgBase64: imgBase64, success: success, failure: failure)
        }, failure: failure)
    }

    func recognize(
        imgURL: URL,
        success: ((String) -> Void)?,
        failure: Failure?) {

        accessToken(success: { oauthResult in
            guard let accessToken = oauthResult.accessToken else {
                failure?("Oauth failed")
                return
            }
            guard let imgBase64 = try? Data(contentsOf: imgURL).base64EncodedString() else { return }
            self.recognize(accessToken: accessToken, imgBase64: imgBase64, success: success, failure: failure)
        }, failure: failure)
    }

    private func accessToken(
        success: ((BaiduOauthToken) -> Void)?,
        failure: Failure?) {

        if let model = BaiduOauthToken.get(), model.isValid {
            success?(model)
            return
        }

        Network.request(
            target: .baiduAccessToken(
                clientId: Constants.BaiduOCR.appKey,
                clientSecret: Constants.BaiduOCR.secretKey),
            success: { data in
                if var oauthResult = BaiduOauthToken.oauthResult(data: data) {
                    let currentTimestamp = Int(Date().timeIntervalSince1970)
                    let expiresIn = oauthResult.expiresIn ?? 2592000
                    let expiryTime = currentTimestamp + expiresIn
                    oauthResult.expiryTimestamp = expiryTime

                    log.info("重新获取 Access Token 成功， 过期时间:", expiryTime)
                    BaiduOauthToken.save(oauthResult)
                    success?(oauthResult)
                } else {
                    failure?("OAuth Fail")
                }

        }, failure: failure)
    }

    private func recognize(
        accessToken: String,
        imgBase64: String,
        success: ((String) -> Void)?,
        failure: Failure?) {

        Network.request(target: .baiduOCRRecognize(
            accessToken: accessToken,
            imgBase64: imgBase64), success: { data in
                guard let response = BaiduOcrResponse.result(data: data) else {
                    failure?("识别失败")
                    return
                }
                log.info(response.dictionaryRepresentation())
                if let errMsg = response.errorMsg {
//                    let errCode = response?.errorCode
                    failure?(errMsg)
                    return
                }

                guard let wordsResult = response.wordsResult else {
                    failure?("识别失败")
                    return
                }

                let wrapperChars: [String] = wordsResult.flatMap({ word in
                    return word.words.deleteOccurrences(target: " ").deleteOccurrences(target: "-").uppercased()
                })

                let chars = wrapperChars.filter { $0.isV2EXCaptcha() }

                guard chars.count.boolValue else {
                    failure?("识别失败"); return
                }

                log.info("filtered recognize values", chars)

                func mostCharIn(_ text: String) -> String {
                    var dict: [String: Int] = [:]
                    var range = NSRange(location: 0, length: 1)
                    for i in 0..<text.count {
                        range.location = i
                        let charStr = text.NSString.substring(with: range)
                        var preCount = 0
                        if let value = dict[charStr] {
                            preCount = value
                        }
                        dict[charStr] = preCount + 1
                    }
                    let sortDict = dict.sorted(by: { (lhs, rhs) -> Bool in
                        return lhs.value > rhs.value
                    })
                    log.info(sortDict)
                    return sortDict.first?.key ?? String(text[0])
                }

                var list: [String] = []
                for offset in 0..<8 {
                    let one = chars.flatMap { $0[offset]}
                    let subStr = mostCharIn(String(one))
                    list.append(subStr)
                }
                let finalCaptcha = list.joined()
                log.info(finalCaptcha)
                success?(finalCaptcha)
        }, failure: failure)
    }
}
