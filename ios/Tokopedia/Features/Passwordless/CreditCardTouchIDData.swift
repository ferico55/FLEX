//
//  CreditCardTouchIDData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

class CreditCardTouchIDData: NSObject, NSCoding {
    let userID: String
    let ccHash: String
    let publicKey: String
    
    public init(userID: String, ccHash: String, publicKey: String) {
        self.userID = userID
        self.ccHash = ccHash
        self.publicKey = publicKey
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let userID = aDecoder.decodeObject(forKey: "userID") as? String,
            let ccHash = aDecoder.decodeObject(forKey: "ccHash") as? String,
            let publicKey = aDecoder.decodeObject(forKey: "publicKey") as? String
            else {
                return nil
        }
        
        self.init(userID: userID, ccHash: ccHash, publicKey: publicKey)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(userID, forKey: "userID")
        aCoder.encode(ccHash, forKey: "ccHash")
        aCoder.encode(publicKey, forKey: "publicKey")
    }
}
