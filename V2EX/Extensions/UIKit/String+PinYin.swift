//
//  File.swift
//  V2EX
//
//  Created by Joe-c on 2017/10/21.
//  Copyright © 2017年 Joe. All rights reserved.
//

import Foundation
import UIKit

extension String {
    // 拼音
    var pinYingString: String {
        let str = NSMutableString(string: self) as CFMutableString
        CFStringTransform(str, nil, kCFStringTransformToLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false)

        let string = str as String
        return string.capitalized.trimmed
    }
    
    // 首字母
    var pinyingInitial: String {
        let array = self.capitalized.components(separatedBy: " ")
        var pinYing = ""
        for temp in array {
            if temp.count == 0 {continue}
            let index = temp.index(temp.startIndex, offsetBy: 1)
            pinYing += temp[..<index]
        }
        return pinYing
        
    }
    
    var firstLetter: String {
        if count == 0 { return self }
        let index = self.index(self.startIndex, offsetBy: 1)
        return String(self[startIndex..<index])
    }
}
