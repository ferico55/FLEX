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
        var tokenDictionary: [AnyHashable: Any?] = [
            "oAuthToken.accessToken": token.accessToken,
            "oAuthToken.tokenType": token.tokenType,
        ]
        
        if token.refreshToken != "" {
            tokenDictionary["oAuthToken.refreshToken"] = token.refreshToken
        }
        tokenDictionary = tokenDictionary.avoidImplicitNil()
        self.storage.setKeychainWith(tokenDictionary)
    }

    func storeLoginInformation(_ loginResult: LoginResult) -> Bool {
        if (loginResult.user_id == nil) {
            return false
        }
        var userDictionary: [AnyHashable: Any?] = [
            "is_login": NSNumber(value: loginResult.is_login),
            "user_id": loginResult.user_id,
            "full_name": loginResult.full_name,
            "short_name": self.getShortNameFromFullName(loginResult.full_name),
            "shop_id": loginResult.shop_id,
            "shop_name": loginResult.shop_name,
            "shop_is_gold": NSNumber(value: loginResult.shop_is_gold),
            "shop_is_official": NSNumber(value: loginResult.shop_is_official),
            "shop_has_term": loginResult.shop_has_terms,
            "msisdn_is_verified": loginResult.msisdn_is_verified,
            "msisdn_show_dialog": loginResult.msisdn_show_dialog,
        ]
        
        if let userImage = loginResult.user_image {
            userDictionary.merge(with: ["user_image" : userImage])
        }
        
        if loginResult.shop_avatar != nil {
            userDictionary.merge(with: ["shop_avatar" : loginResult.shop_avatar])
        }
        
        if let userReputation = loginResult.user_reputation {
            userDictionary.merge(with: [
                "has_reputation": NSNumber(value: true),
                "reputation_positive": userReputation.positive,
                "reputation_positive_percentage": userReputation.positive_percentage,
                "no_reputation": userReputation.no_reputation,
                "reputation_negative": userReputation.negative,
                "reputation_neutral": userReputation.neutral
                ])
        }
        userDictionary = userDictionary.avoidImplicitNil()
        self.storage.setKeychainWith(userDictionary)
        return true
    }
    
    func storeUserInformation(_ user: ProfileInfoResult) {
        guard let userInfo = user.user_info else { return }
        
        let convertedNumber = userInfo.user_phone.replacingPrefix(of: "0", with: "62")
        
        var userDictionary: [AnyHashable: Any?] = [
            "full_name": userInfo.user_name,
            "short_name": self.getShortNameFromFullName((userInfo.user_name)!),
            "user_id": userInfo.user_id,
            "user_phone": convertedNumber,
            "user_hobbies": userInfo.user_hobbies,
            "user_email": userInfo.user_email,
            "dob": userInfo.user_birth,
        ]
        
        if let userImage = userInfo.user_image {
            userDictionary.merge(with: ["user_image" : userImage])
        }
        
        if let userReputation = userInfo.user_reputation {
            userDictionary.merge(with: [
                "has_reputation": NSNumber(value: true),
                "reputation_positive": userReputation.positive,
                "reputation_positive_percentage": userReputation.positive_percentage,
                "no_reputation": userReputation.no_reputation,
                "reputation_negative": userReputation.negative,
                "reputation_neutral": userReputation.neutral
                ])
        }
        userDictionary = userDictionary.avoidImplicitNil()
        self.storage.setKeychainWith(userDictionary)
    }
    
    func storeShopInformation(_ user: ProfileInfoResult) {
        guard let shopInfo = user.shop_info else { return }
        guard let shopStats = user.shop_stats else { return }
        
        let shopDictionary: [AnyHashable: Any?] = [
            "total_sold_item": shopStats.shop_item_sold,
            "shop_location": shopInfo.shop_location,
            "date_shop_created": shopInfo.shop_open_since,
        ]
        let safeDictionary = shopDictionary.avoidImplicitNil()
        self.storage.setKeychainWith(safeDictionary)
    }
    
    func storeAnalyticsInformation(data: MoEngageQuery.Data) {
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
        let tokocashAmount = data.wallet?.rawBalance ?? 0
        let saldoAmount = data.saldo?.deposit ?? 0
        let topAdsAmount = data.topadsDeposit?.topadsAmount ?? 0
        let isTopAdsUser = data.topadsDeposit?.isTopadsUser ?? false
        let hasPurchasedMarketplace = data.paymentAdminProfile?.isPurchasedMarketplace ?? false
        let hasPurchasedDigital = data.paymentAdminProfile?.isPurchasedDigital ?? false
        let hasPurchasedTicket = data.paymentAdminProfile?.isPurchasedTicket ?? false
        let lastPurchasedDate = data.paymentAdminProfile?.lastPurchaseDate ?? ""
        let totalActiveProduct = data.shopInfoMoengage?.info?.totalActiveProduct ?? 0
        let shopScore = data.shopInfoMoengage?.info?.shopScore ?? 0
        
        let analyticsDictionary: [AnyHashable: Any?] = [
            "is_seller": NSNumber(value: isSeller),
            "gender": gender,
            "city": city,
            "province": province,
            "registration_date": registerDate,
            "is_tokocash_active": NSNumber(value: isTokocashActive),
            "is_topads_user": NSNumber(value: isTopAdsUser),
            "has_purchased_marketplace": NSNumber(value: hasPurchasedMarketplace),
            "has_purchased_digital": NSNumber(value: hasPurchasedDigital),
            "has_purchased_tiket": NSNumber(value: hasPurchasedTicket),
            "tokocash_amt": tokocashAmount,
            "saldo_amt": saldoAmount,
            "topads_amount": topAdsAmount,
            "last_transaction_date": lastPurchasedDate,
            "total_active_product": totalActiveProduct,
            "shop_score": shopScore,
        ]
        let safeDictionary = analyticsDictionary.avoidImplicitNil()
        self.storage.setKeychainWith(safeDictionary)
    }
    
    func storeTokoCashToken(_ token: String) {
        self.storage.setKeychainWithValue(token, withKey: "tokocash_token")
    }
    
    private func getShortNameFromFullName(_ fullName: String) -> String {
        let fullNameArr = fullName.components(separatedBy: " ")
        
        return fullNameArr.first!
    }
}
