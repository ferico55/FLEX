//
//  SignInProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import RestKit
import UIKit

public enum ProviderType {
    case login
    case register
}

public class SignInProvider: NSObject {
    public var id: String = ""
    public var name: String = ""
    public var signInUrl: String = ""
    public var imageUrl: String = ""
    public var color: String = ""

    class public func mapping() -> RKObjectMapping {
        if let mapping = RKObjectMapping(for: self) {
            mapping.addAttributeMappings(from: [
                "id": "id",
                "name": "name",
                "url": "signInUrl",
                "image": "imageUrl",
                "color": "color"
                ])
            return mapping
        }
        
        return RKObjectMapping()
    }

    class public func defaultProviders(useFor: ProviderType) -> [SignInProvider] {
        // MARK : List of Provider
        let fbProvider = SignInProvider()
        fbProvider.name = "Facebook"
        fbProvider.id = "facebook"
        fbProvider.imageUrl = "https://ecs7.tokopedia.net/img/icon/facebook_icon.png"
        fbProvider.color = "#ffffff"
        
        let googleProvider = SignInProvider()
        googleProvider.name = "Google"
        googleProvider.id = "gplus"
        googleProvider.imageUrl = "https://ecs7.tokopedia.net/img/icon/gplus_icon.png"
        googleProvider.color = "#ffffff"
        
        let yahooProvider = SignInProvider()
        yahooProvider.name = "Yahoo"
        yahooProvider.id = "yahoo"
        yahooProvider.signInUrl = "\(NSString.accountsUrl())/wv/yahoo-login"
        yahooProvider.imageUrl = "https://ecs7.tokopedia.net/img/icon/yahoo_icon.png"
        yahooProvider.color = "#ffffff"
        
        let tokoCashProvider = SignInProvider()
        tokoCashProvider.name = "Nomor Ponsel"
        tokoCashProvider.id = "phoneNumber"
        tokoCashProvider.imageUrl = ""
        tokoCashProvider.color = "#ffffff"
        
        let emailProvider = SignInProvider()
        emailProvider.name = "Email"
        emailProvider.id = "regemail"
        emailProvider.imageUrl = ""
        emailProvider.color = "#ffffff"
        
        if useFor == .login {
            let loginProvider : [SignInProvider] = [
                fbProvider,
                googleProvider,
                tokoCashProvider,
                yahooProvider
            ]
            return loginProvider
        } else {
            let registerProvider : [SignInProvider] = [
                fbProvider,
                googleProvider,
                emailProvider
            ]
            return registerProvider
        }
    }
    
    class public func touchIdProvider() -> SignInProvider {
        let provider = SignInProvider()
        provider.name = NSString.authenticationType()
        provider.id = "touchid"
        provider.imageUrl = ""
        provider.color = "#ffffff"
        return provider
    }
}
