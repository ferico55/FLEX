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
        self.storage.setKeychainWithValue(convertedNumber, withKey: "user_phone")
        self.storage.setKeychainWithValue(userInfo.user_hobbies, withKey: "user_hobbies")
        self.storage.setKeychainWithValue(userInfo.user_email, withKey: "user_email")
        self.storage.setKeychainWithValue(userInfo.user_birth, withKey: "dob")
        
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
    
    func storeAnalyticsInformation(data:MoEngageQuery.Data) {
        let isSeller = data.shopInfoMoengage?.owner?.isSeller ?? false
        let gender = data.profile?.gender ?? ""
        var city = ""
        var province = ""
        if let address = data.address {
            if let addresses = address.addresses {
                if addresses.count > 0 {
                    if let cityName = addresses[0]?.cityName {
                        city = cityName
                    }
                    if let provinceName = addresses[0]?.provinceName {
                        province = provinceName
                    }
                }
            }
        }
        let registerDate = data.profile?.registerDate ?? ""
        let isTokocashActive = data.wallet?.linked ?? false
        let tokocashAmount = data.wallet?.balance ?? "0"
        let saldoAmount = data.saldo?.depositFmt ?? "0"
        let topAdsAmount = String(describing: data.topadsDeposit?.topadsAmount ?? 0)
        let isTopAdsUser = data.topadsDeposit?.isTopadsUser ?? false
        let hasPurchasedMarketplace = data.paymentAdminProfile?.isPurchasedMarketplace ?? false
        let hasPurchasedDigital = data.paymentAdminProfile?.isPurchasedDigital ?? false
        let hasPurchasedTicket = data.paymentAdminProfile?.isPurchasedTicket ?? false
        let lastPurchasedDate = data.paymentAdminProfile?.lastPurchaseDate ?? ""
        let totalActiveProduct = data.shopInfoMoengage?.info?.totalActiveProduct ?? 0
        let shopScore = data.shopInfoMoengage?.info?.shopScore ?? 0
        
        self.storage.setKeychainWithValue(NSNumber(value:isSeller), withKey: "is_seller")
        self.storage.setKeychainWithValue(gender, withKey: "gender")
        self.storage.setKeychainWithValue(city, withKey: "city")
        self.storage.setKeychainWithValue(province, withKey: "province")
        self.storage.setKeychainWithValue(registerDate, withKey: "registration_date")
        
        self.storage.setKeychainWithValue(NSNumber(value:isTokocashActive), withKey: "is_tokocash_active")
        self.storage.setKeychainWithValue(tokocashAmount, withKey: "tokocash_amt")
        self.storage.setKeychainWithValue(saldoAmount, withKey: "saldo_amt")
        self.storage.setKeychainWithValue(topAdsAmount, withKey: "topads_amount")
        self.storage.setKeychainWithValue(NSNumber(value:isTopAdsUser), withKey: "is_topads_user")
        self.storage.setKeychainWithValue(NSNumber(value:hasPurchasedMarketplace), withKey: "has_purchased_marketplace")
        self.storage.setKeychainWithValue(NSNumber(value:hasPurchasedDigital), withKey: "has_purchased_digital")
        self.storage.setKeychainWithValue(NSNumber(value:hasPurchasedTicket), withKey: "has_purchased_tiket")
        self.storage.setKeychainWithValue(lastPurchasedDate, withKey: "last_transaction_date")
        self.storage.setKeychainWithValue(totalActiveProduct, withKey: "total_active_product")
        self.storage.setKeychainWithValue(shopScore, withKey: "shop_score")
    }
    
    private func getShortNameFromFullName(_ fullName: String) -> String {
        let fullNameArr = fullName.components(separatedBy: " ")
        
        return fullNameArr.first!
    }
}
