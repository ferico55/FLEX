//
//  PaymentUseCase.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public class PaymentUseCase {
    
    class public func requestListCreditCardData() -> Observable<CreditCardResponse> {
        return ScroogeProvider()
            .request(.getListCreditCard())
            .map(to: CreditCardResponse.self)
    }
    
    class public func requestDeleteCC(_ tokenID: String) -> Observable<PaymentActionResponse> {
        return ScroogeProvider()
            .request(.deleteCreditCard(tokenID))
            .map(to: PaymentActionResponse.self)
    }
    
    class public func requestCCRegisterIframe() -> Observable<CCRegisterIframeResponse> {
        return NetworkProvider<PaymentTarget>()
            .request(.ccRegistrationIframe())
            .map(to: CCRegisterIframeResponse.self)
        
    }
}
