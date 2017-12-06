import Foundation

public struct BaiduOauthToken: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case sessionSecret = "session_secret"
        case expiresIn = "expires_in"
        case sessionKey = "session_key"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
    }
    
    // MARK: Properties
    public var sessionSecret: String?
    public var expiresIn: Int?
    public var sessionKey: String?
    public var refreshToken: String?
    public var accessToken: String?

    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = sessionSecret { dictionary[CodingKeys.sessionSecret.rawValue] = value }
        if let value = expiresIn { dictionary[CodingKeys.expiresIn.rawValue] = value }
        if let value = sessionKey { dictionary[CodingKeys.sessionKey.rawValue] = value }
        if let value = refreshToken { dictionary[CodingKeys.refreshToken.rawValue] = value }
        if let value = accessToken { dictionary[CodingKeys.accessToken.rawValue] = value }
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
}


public struct BaiduOauthError: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case error = "error"
        case errorDescription = "error_description"
    }

    // 错误说明
    // 链接: http://ai.baidu.com/docs#/Auth/top
    //    error             error_description               解释
    //    invalid_client    unknown client id               API Key不正确
    //    invalid_client    Client authentication failed    Secret Key不正确
    var error: String?
    var errorDescription: String?
    
    static func result(data: Data) -> BaiduOauthError? {
        do {
            return try JSONDecoder().decode(BaiduOauthError.self, from: data)
        } catch {
            HUD.showTest(error.localizedDescription)
            log.error(error)
            return nil
        }
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
    
    /// 错误码。
    var errorMsg: String?
    
    /// 错误描述信息，帮助理解和解决发生的错误。
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
}

public struct WordResult: Codable {
    var words: String = ""
}
