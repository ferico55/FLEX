//
//  StringExtension.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 28/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

extension String {
    internal func toMD5() -> String {
        let messageData = self.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.base64EncodedString()
    }
    
    internal func isValidHexColor() -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", "#?([0-9A-F]{3}|[0-9A-F]{6})")
        let newValue = self.uppercased()
        let result = test.evaluate(with: newValue)
        return result
    }
}
