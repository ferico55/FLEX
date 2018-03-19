//
//  PaymentDetailViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public final class PaymentDetailCCViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let deleteCCTrigger: Driver<Void>
    }
    
    public struct Output {
        public let ccImageURL: Driver<URL?>
        public let ccNumber: Driver<String>
        public let ccExpiry: Driver<String>
        public let isHiddenRegisterFingerprint: Driver<Bool>
        public let activityIndicator: Driver<Bool>
        public let successMessage: Driver<String>
        public let successTrigger: Driver<Void>
        public let failedMessage: Driver<String>
    }
    
    private let creditCard: CreditCardData
    private let navigator: PaymentDetailCCNavigator
    
    public init(creditCard: CreditCardData, navigator: PaymentDetailCCNavigator) {
        self.creditCard = creditCard
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let creditCard = input.trigger.flatMapLatest {
            Driver.of(self.creditCard)
        }
        
        let ccImageURL = creditCard.map { creditCard -> URL? in
            return URL(string: creditCard.backgroundImage)
        }
        
        let ccNumber = creditCard.map { creditCard -> String in
            return self.insert(seperator: " ", afterEveryXChars: 4, intoString: creditCard.number)
        }.startWith("")
        
        let ccExpiry = creditCard.map { creditCard -> String in
            return "\(creditCard.expiryMonth)/\(creditCard.expiryYear)"
        }.startWith("")
        
        let isHiddenRegisterFingerprint = Driver.just(true)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let deleteCCResponse = input.deleteCCTrigger.withLatestFrom(creditCard)
            .flatMapLatest { creditCard -> SharedSequence<DriverSharingStrategy, PaymentActionResponse> in
                return PaymentUseCase.requestDeleteCC(creditCard.tokenID)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let successMessage = deleteCCResponse
            .filter { response -> Bool in
                response.success
            }.map { _ -> String in
                return "Berhasil menghapus kartu kredit"
            }
        
        let successTrigger = successMessage.delay(0.7).mapToVoid()
        
        let failedMessage = deleteCCResponse
            .filter { response -> Bool in
                !response.success
            }.map { _ -> String in
                return "Gagal menghapus kartu kredit"
            }
        
        return Output(ccImageURL: ccImageURL,
                      ccNumber: ccNumber,
                      ccExpiry: ccExpiry,
                      isHiddenRegisterFingerprint: isHiddenRegisterFingerprint,
                      activityIndicator: activityIndicator.asDriver(),
                      successMessage: successMessage,
                      successTrigger: successTrigger,
                      failedMessage: failedMessage)
    }
    
    private func insert(seperator: String, afterEveryXChars: Int, intoString: String) -> String {
        var output = ""
        intoString.enumerated().forEach { index, character in
            if index % afterEveryXChars == 0 && index > 0 {
                output += seperator
            }
            output.append(character)
        }
        return output
    }
}
