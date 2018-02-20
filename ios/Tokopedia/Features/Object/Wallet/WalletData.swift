//
//  UWalletData.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final public class WalletData: NSObject, Unboxable {
    public let action: WalletAction?
    public var balance: String
    public let rawBalance: Int
    public let totalBalance: String
    public let rawTotalBalance: Int
    public let holdBalance: String
    public let rawHoldBalance: Int
    public let rawThreshold: Int
    public let text: String
    public let redirectUrl: String
    public let link: Int
    public var hasPendingCashback: Bool
    public let applinks: String
    public let abTags: [String]
    
    public init(action: WalletAction?,
         balance: String = "",
         rawBalance: Int = 0,
         totalBalance: String = "",
         rawTotalBalance: Int = 0,
         holdBalance: String = "",
         rawHoldBalance: Int = 0,
         rawThreshold: Int = 0,
         text: String = "",
         redirectUrl: String = "",
         link: Int = 0,
         hasPendingCashback: Bool = false,
         applinks: String = "",
         abTags: [String] = [String]()) {
        
        self.action = action
        self.balance = balance
        self.rawBalance = rawBalance
        self.totalBalance = totalBalance
        self.rawTotalBalance = rawTotalBalance
        self.holdBalance = holdBalance
        self.rawHoldBalance = rawHoldBalance
        self.rawThreshold = rawThreshold
        self.text = text
        self.redirectUrl = redirectUrl
        self.link = link
        self.hasPendingCashback = hasPendingCashback
        self.applinks = applinks
        self.abTags = abTags
    }
    
    convenience public init(unboxer: Unboxer) throws {
        let action = unboxer.unbox(keyPath: "action") as WalletAction?
        let balance = try unboxer.unbox(keyPath: "balance") as String
        let rawBalance = try unboxer.unbox(keyPath: "raw_balance") as Int
        let totalBalance = try unboxer.unbox(keyPath: "total_balance") as String
        let rawTotalBalance = try unboxer.unbox(keyPath: "raw_total_balance") as Int
        let holdBalance = try unboxer.unbox(keyPath: "hold_balance") as String
        let rawHoldBalance = try unboxer.unbox(keyPath: "raw_hold_balance") as Int
        let rawThreshold = try? unboxer.unbox(keyPath: "raw_threshold") as Int
        let text = try unboxer.unbox(keyPath: "text") as String
        let redirectUrl = try unboxer.unbox(keyPath: "redirect_url") as String
        let link = try unboxer.unbox(keyPath: "link") as Int
        let applinks = try unboxer.unbox(key: "applinks") as String
        let abTags = try unboxer.unbox(key: "ab_tags") as [String]
        
        self.init(action: action,
                  balance: balance,
                  rawBalance: rawBalance,
                  totalBalance: totalBalance,
                  rawTotalBalance: rawTotalBalance,
                  holdBalance: holdBalance,
                  rawHoldBalance: rawHoldBalance,
                  rawThreshold: rawThreshold ?? 0,
                  text: text,
                  redirectUrl: redirectUrl,
                  link: link,
                  hasPendingCashback: false,
                  applinks: applinks,
                  abTags: abTags)
    }
    
    public func walletActionFullUrl() -> String {
        if let action = self.action {
            return "\(action.redirectUrl)?flag_app=1"
        }
        
        return ""
    }
}
