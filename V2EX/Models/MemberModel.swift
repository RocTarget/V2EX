//
//  MemberModel.swift
//  V2EX
//
//  Created by Joe-c on 2017/10/16.
//  Copyright © 2017年 Joe. All rights reserved.
//

import Foundation

struct MemberModel {
    
    public var username: String
    public var url: String
    public var avatar: String
    
    public var avatarSrc: String {
        return Constants.Config.URIScheme + avatar
    }
    
    init(username: String, url: String, avatar: String) {
        self.username = username
        self.url = url
        self.avatar = avatar
    }
}

extension MemberModel: Hashable {
    static func ==(lhs: MemberModel, rhs: MemberModel) -> Bool {
        return lhs.username == rhs.username && lhs.url == rhs.url && lhs.avatar == rhs.avatar
    }

    var hashValue: Int {
        return "\(username),\(url),\(avatar)".hashValue
    }
}
