//
//  PaymentCCViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 26/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public final class PaymentCCViewModel {
    
    public struct Input {
    }
    
    public struct Output {
        public let ccNumber: Driver<String>
        public let ccImage: Driver<URL?>
    }
    
    private let creditCardData: CreditCardData
    
    public init(with creditCardData: CreditCardData) {
        self.creditCardData = creditCardData
    }
    
    public func transform(input: Input) -> Output {
        
        let creditCardData = Driver.of(self.creditCardData)
        
        let ccNumber = creditCardData.map { creditCardData -> String in
            return creditCardData.number
        }
        
        let ccImage = creditCardData.map { creditCardData -> URL? in
            return URL(string: creditCardData.smallBackgroundImage)
        }
        
        return Output(ccNumber: ccNumber,
                      ccImage: ccImage)
    }
}
