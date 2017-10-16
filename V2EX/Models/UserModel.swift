import Foundation

final class UserModel: NSCoding {

    private struct SerializationKeys {
        static let avatarNormal = "avatar_normal"
        static let twitter = "twitter"
        static let github = "github"
        static let avatarMini = "avatar_mini"
        static let website = "website"
        static let bio = "bio"
        static let psn = "psn"
        static let username = "username"
        static let status = "status"
        static let location = "location"
        static let id = "id"
        static let created = "created"
        static let btc = "btc"
        static let tagline = "tagline"
        static let avatarLarge = "avatar_large"
        static let url = "url"
    }

    // MARK: Properties
    public var twitter: String?
    public var github: String?
    public var website: String?
    public var bio: String?
    public var psn: String?
    public var username: String
    public var status: String?
    public var location: String?
    public var id: Int?
    public var created: Int?
    public var btc: String?
    public var url: String
    public var tagline: String?
    public var avatarMini: String?
    public var avatarNormal: String
    public var avatarLarge: String?

//    var name: String
//    var href: String
//    var avatar: String

    var avatarNormalSrc: String {
        return "https:" + avatarNormal
    }

    init(username: String, url: String, avatar: String) {
        self.username = username
        self.url = url
        self.avatarNormal = avatar
    }

    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[SerializationKeys.avatarNormal] = avatarNormal
        dictionary[SerializationKeys.username] = username
        dictionary[SerializationKeys.url] = url
        if let value = twitter { dictionary[SerializationKeys.twitter] = value }
        if let value = github { dictionary[SerializationKeys.github] = value }
        if let value = avatarMini { dictionary[SerializationKeys.avatarMini] = value }
        if let value = website { dictionary[SerializationKeys.website] = value }
        if let value = bio { dictionary[SerializationKeys.bio] = value }
        if let value = psn { dictionary[SerializationKeys.psn] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = location { dictionary[SerializationKeys.location] = value }
        if let value = id { dictionary[SerializationKeys.id] = value }
        if let value = created { dictionary[SerializationKeys.created] = value }
        if let value = btc { dictionary[SerializationKeys.btc] = value }
        if let value = tagline { dictionary[SerializationKeys.tagline] = value }
        if let value = avatarLarge { dictionary[SerializationKeys.avatarLarge] = value }
        return dictionary
    }

    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.avatarNormal = aDecoder.decodeObject(forKey: SerializationKeys.avatarNormal) as? String ?? "//v2ex.assets.uxengine.net/gravatar/831f422d3ac06300f8076b3e4b518c43?s=48&d=retro"
        self.twitter = aDecoder.decodeObject(forKey: SerializationKeys.twitter) as? String
        self.github = aDecoder.decodeObject(forKey: SerializationKeys.github) as? String
        self.avatarMini = aDecoder.decodeObject(forKey: SerializationKeys.avatarMini) as? String
        self.website = aDecoder.decodeObject(forKey: SerializationKeys.website) as? String
        self.bio = aDecoder.decodeObject(forKey: SerializationKeys.bio) as? String
        self.psn = aDecoder.decodeObject(forKey: SerializationKeys.psn) as? String
        self.username = aDecoder.decodeObject(forKey: SerializationKeys.username) as? String ?? "Unkown"
        self.status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? String
        self.location = aDecoder.decodeObject(forKey: SerializationKeys.location) as? String
        self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? Int
        self.created = aDecoder.decodeObject(forKey: SerializationKeys.created) as? Int
        self.btc = aDecoder.decodeObject(forKey: SerializationKeys.btc) as? String
        self.tagline = aDecoder.decodeObject(forKey: SerializationKeys.tagline) as? String
        self.avatarLarge = aDecoder.decodeObject(forKey: SerializationKeys.avatarLarge) as? String
        self.url = aDecoder.decodeObject(forKey: SerializationKeys.url) as? String ?? ""
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(avatarNormal, forKey: SerializationKeys.avatarNormal)
        aCoder.encode(twitter, forKey: SerializationKeys.twitter)
        aCoder.encode(github, forKey: SerializationKeys.github)
        aCoder.encode(avatarMini, forKey: SerializationKeys.avatarMini)
        aCoder.encode(website, forKey: SerializationKeys.website)
        aCoder.encode(bio, forKey: SerializationKeys.bio)
        aCoder.encode(psn, forKey: SerializationKeys.psn)
        aCoder.encode(username, forKey: SerializationKeys.username)
        aCoder.encode(status, forKey: SerializationKeys.status)
        aCoder.encode(location, forKey: SerializationKeys.location)
        aCoder.encode(id, forKey: SerializationKeys.id)
        aCoder.encode(created, forKey: SerializationKeys.created)
        aCoder.encode(btc, forKey: SerializationKeys.btc)
        aCoder.encode(tagline, forKey: SerializationKeys.tagline)
        aCoder.encode(avatarLarge, forKey: SerializationKeys.avatarLarge)
        aCoder.encode(url, forKey: SerializationKeys.url)
    }
}
