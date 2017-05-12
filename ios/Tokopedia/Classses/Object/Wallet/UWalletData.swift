//
//  UWalletData.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class WalletData:NSObject, Unboxable {
    let action: WalletAction?
    let balance: String
    let text: String
    let redirectUrl: String
    let link: Int
    
    init(action:WalletAction?, balance:String, text:String, redirectUrl:String, link:Int) {
        self.action = action
        self.balance = balance
        self.text = text
        self.redirectUrl = redirectUrl
        self.link = link
    }
    
    convenience init(unboxer: Unboxer) throws {
        let action = unboxer.unbox(keyPath: "action") as WalletAction?
        let balance = try unboxer.unbox(keyPath: "balance") as String
        let text = try unboxer.unbox(keyPath: "text") as String
        let redirectUrl = try unboxer.unbox(keyPath: "redirect_url") as String
        let link = try unboxer.unbox(keyPath: "link") as Int
        
        
        self.init(action:action, balance:balance, text:text, redirectUrl:redirectUrl, link:link)
    }
    
    func walletActionFullUrl() -> String {
        if let action = self.action {
            return "\(action.redirectUrl)?flag_app=1"
        }
        
        return ""
    }
}
