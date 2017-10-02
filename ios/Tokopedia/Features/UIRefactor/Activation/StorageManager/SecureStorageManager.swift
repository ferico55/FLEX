//
//  SecureStorageManager.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SecureStorageManager: NSObject {
    
    private let storage: TKPDSecureStorage!
    
    override init() {
        self.storage = TKPDSecureStorage.standardKeyChains()
        super.init()
    }
    
    func resetKeychain() {
        self.storage.resetKeychain()
    }
    
    func storeToken(_ token: OAuthToken) {
        self.storage.setKeychainWithValue(token.accessToken, withKey: "oAuthToken.accessToken")
        self.storage.setKeychainWithValue(token.tokenType, withKey: "oAuthToken.tokenType")
        
        if token.refreshToken != "" {
            self.storage.setKeychainWithValue(token.refreshToken, withKey: "oAuthToken.refreshToken")
        }
    }
    
    func storeLoginInformation(_ loginResult: LoginResult) {
        self.storage.setKeychainWithValue(NSNumber(value: loginResult.is_login), withKey: "is_login")
        self.storage.setKeychainWithValue(loginResult.user_id, withKey: "user_id")
        self.storage.setKeychainWithValue(loginResult.full_name, withKey: "full_name")
        self.storage.setKeychainWithValue(self.getShortNameFromFullName(loginResult.full_name), withKey: "short_name")
        if let userImage = loginResult.user_image {
            self.storage.setKeychainWithValue(userImage, withKey: "user_image")
        }
        
        self.storage.setKeychainWithValue(loginResult.shop_id, withKey: "shop_id")
        self.storage.setKeychainWithValue(loginResult.shop_name, withKey: "shop_name")
        self.storage.setKeychainWithValue(NSNumber(value: loginResult.shop_is_gold), withKey: "shop_is_gold")
        self.storage.setKeychainWithValue(NSNumber(value: loginResult.shop_is_official), withKey: "shop_is_official")
        self.storage.setKeychainWithValue(loginResult.shop_has_terms, withKey: "shop_has_term")
        if loginResult.shop_avatar != nil {
            self.storage.setKeychainWithValue(loginResult.shop_avatar, withKey: "shop_avatar")
        }
        
        self.storage.setKeychainWithValue(loginResult.msisdn_is_verified, withKey: "msisdn_is_verified")
        self.storage.setKeychainWithValue(loginResult.msisdn_show_dialog, withKey: "msisdn_show_dialog")
        
        if let userReputation = loginResult.user_reputation {
            self.storage.setKeychainWithValue(NSNumber(value: true), withKey: "has_reputation")
            self.storage.setKeychainWithValue(userReputation.positive, withKey: "reputation_positive")
            self.storage.setKeychainWithValue(userReputation.positive_percentage, withKey: "reputation_positive_percentage")
            self.storage.setKeychainWithValue(userReputation.no_reputation, withKey: "no_reputation")
            self.storage.setKeychainWithValue(userReputation.negative, withKey: "reputation_negative")
            self.storage.setKeychainWithValue(userReputation.neutral, withKey: "reputation_neutral")
        }
    }
    
    func storeUserInformation(_ user: ProfileInfoResult) {
        guard let userInfo = user.user_info else { return }
        
        let convertedNumber = userInfo.user_phone.replacingPrefix(of: "0", with: "62")
        
        self.storage.setKeychainWithValue(userInfo.user_name, withKey: "full_name")
        self.storage.setKeychainWithValue(self.getShortNameFromFullName((userInfo.user_name)!), withKey: "short_name")
        self.storage.setKeychainWithValue(userInfo.user_id, withKey: "user_id")
        self.storage.setKeychainWithValue(userInfo.user_birth, withKey: "user_birth")
        self.storage.setKeychainWithValue(convertedNumber, withKey: "user_phone")
        self.storage.setKeychainWithValue(userInfo.user_hobbies, withKey: "user_hobbies")
        self.storage.setKeychainWithValue(userInfo.user_email, withKey: "user_email")
        
        self.storage.setKeychainWithValue(userInfo.user_birth, withKey: "dob")
        self.storage.setKeychainWithValue("", withKey: "city")
        self.storage.setKeychainWithValue("", withKey: "province")
        self.storage.setKeychainWithValue("", withKey: "registration_date")
        
        if let userImage = userInfo.user_image {
            self.storage.setKeychainWithValue(userImage, withKey: "user_image")
        }
        
        if let userReputation = userInfo.user_reputation {
            self.storage.setKeychainWithValue(NSNumber(value: true), withKey: "has_reputation")
            self.storage.setKeychainWithValue(userReputation.positive, withKey: "reputation_positive")
            self.storage.setKeychainWithValue(userReputation.positive_percentage, withKey: "reputation_positive_percentage")
            self.storage.setKeychainWithValue(userReputation.no_reputation, withKey: "no_reputation")
            self.storage.setKeychainWithValue(userReputation.negative, withKey: "reputation_negative")
            self.storage.setKeychainWithValue(userReputation.neutral, withKey: "reputation_neutral")
        }
    }
    
    func storeShopInformation(_ user: ProfileInfoResult) {
        guard let shopInfo = user.shop_info else { return }
        guard let shopStats = user.shop_stats else { return }
        
        self.storage.setKeychainWithValue(shopStats.shop_item_sold, withKey: "total_sold_item")
        self.storage.setKeychainWithValue(shopInfo.shop_location, withKey: "shop_location")
        self.storage.setKeychainWithValue(shopInfo.shop_open_since, withKey: "date_shop_created")
    }
    
    private func getShortNameFromFullName(_ fullName: String) -> String {
        let fullNameArr = fullName.components(separatedBy: " ")
        
        return fullNameArr.first!
    }
}
