import Foundation

struct UserModel {
    var name: String
    var href: String
    var avatar: String
    
    var avatarSrc: String {
        return "https:" + avatar
    }
}
