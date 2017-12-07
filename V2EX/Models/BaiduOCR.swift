import Foundation

public struct BaiduAppearence: Codable {
//    var appId: String
    var appkey: String
    var secretKey: String
    
    func save() {
        do {
            let enc = try JSONEncoder().encode(self)
            let error = FileManager.save(enc, savePath: Constants.Keys.baiduAppearence)
            if let `error` = error {
                HUD.showTest(error)
                log.error(error)
            }
        } catch {
            HUD.showTest(error)
            log.error(error)
        }
    }
    
    static func get() -> BaiduAppearence? {
        guard FileManager.default.fileExists(atPath: Constants.Keys.baiduAppearence) else { return nil }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: Constants.Keys.baiduAppearence))
            return try JSONDecoder().decode(BaiduAppearence.self, from: data)
        } catch {
            HUD.showTest(error)
            log.error(error)
            return nil
        }
    }
}

public struct BaiduOauthToken: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case expiresIn = "expires_in"
        case accessToken = "access_token"

        case error = "error"
        case errorDescription = "error_description"

        case expiryTimestamp = "expiryTimestamp"
    }
    
    // MARK: Properties
    public var expiresIn: Int?
    public var accessToken: String?
    public var expiryTimestamp: Int?
    public var isUser: Bool? = false

    public var isValid: Bool {
        guard let expiryTimestamp = expiryTimestamp,
            let _ = accessToken else { return false }
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        return currentTimestamp < expiryTimestamp
    }

    // 错误说明
    // 链接: http://ai.baidu.com/docs#/Auth/top
    //    error             error_description               解释
    //    invalid_client    unknown client id               API Key不正确
    //    invalid_client    Client authentication failed    Secret Key不正确
    var error: String?
    var errorDescription: String?

    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = expiresIn { dictionary[CodingKeys.expiresIn.rawValue] = value }
        if let value = accessToken { dictionary[CodingKeys.accessToken.rawValue] = value }
        if let value = expiryTimestamp { dictionary[CodingKeys.expiryTimestamp.rawValue] = value }
        return dictionary
    }

    static func oauthResult(data: Data) -> BaiduOauthToken? {
        do {
            return try JSONDecoder().decode(BaiduOauthToken.self, from: data)
        } catch {
            HUD.showTest(error.localizedDescription)
            log.error(error)
            return nil
        }
    }

    static func save(_ model: BaiduOauthToken) {
        do {
            let enc = try JSONEncoder().encode(model)
            let error = FileManager.save(enc, savePath: Constants.Keys.baiduOauthToken)
            if let `error` = error {
                HUD.showTest(error)
                log.error(error)
            }
        } catch {
            HUD.showTest(error)
            log.error(error)
        }
    }

    static func get() -> BaiduOauthToken? {
        guard FileManager.default.fileExists(atPath: Constants.Keys.baiduOauthToken) else { return nil }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: Constants.Keys.baiduOauthToken))
            return try JSONDecoder().decode(BaiduOauthToken.self, from: data)
        } catch {
            HUD.showTest(error)
            log.error(error)
            return nil
        }
    }
    
    static func remove() {
        FileManager.delete(at: Constants.Keys.baiduOauthToken)
    }
}

public struct BaiduOcrResponse: Codable {

    private enum CodingKeys: String, CodingKey {
        case logId = "log_id"
        case wordsResultNum = "words_result_num"
        case wordsResult = "words_result"
        case errorMsg = "error_msg"
        case errorCode = "error_code"
        case probability = "probability"
    }
    
    /// 唯一的log id，用于问题定位
    var logId: Int?
    
    /// 识别结果数，表示words_result的元素个数
    var wordsResultNum: Int?
    
    /// 识别结果数组
    var wordsResult: [WordResult]?
    
    /// 识别结果中每一行的置信度值，包含average：行置信度平均值，variance：行置信度方差，min：行置信度最小值
    var probability: String?

    /// 错误说明： https://cloud.baidu.com/doc/OCR/OCR-API.html#.E9.94.99.E8.AF.AF.E7.A0.81
    /// 错误描述信息，帮助理解和解决发生的错误。
    var errorMsg: String?
    /// 错误码。
    var errorCode: Int?
    
    static func result(data: Data) -> BaiduOcrResponse? {
        do {
            return try JSONDecoder().decode(BaiduOcrResponse.self, from: data)
        } catch {
            HUD.showTest(error.localizedDescription)
            log.error(error)
            return nil
        }
    }

    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = logId { dictionary[CodingKeys.logId.rawValue] = value }
        if let value = wordsResultNum { dictionary[CodingKeys.wordsResultNum.rawValue] = value }
        if let value = wordsResult { dictionary[CodingKeys.wordsResult.rawValue] = value }
        if let value = probability { dictionary[CodingKeys.probability.rawValue] = value }
        if let value = errorMsg { dictionary[CodingKeys.errorMsg.rawValue] = value }
        if let value = errorCode { dictionary[CodingKeys.errorCode.rawValue] = value }
        return dictionary
    }
}

public struct WordResult: Codable {
    var words: String = ""
}
