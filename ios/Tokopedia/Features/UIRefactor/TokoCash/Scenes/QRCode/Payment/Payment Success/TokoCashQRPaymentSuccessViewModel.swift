//
//  TokoCashQRPaymentSuccessViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashQRPaymentSuccessViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let backToHomeTrigger: Driver<Void>
        public let helpTrigger: Driver<Void>
    }
    
    public struct Output {
        public let merchantName: Driver<String>
        public let amount: Driver<String>
        public let datetime: Driver<String>
        public let transactionId: Driver<String>
        public let balance: Driver<String>
        public let backToHome: Driver<Void>
        public let help: Driver<String>
    }
    
    private let paymentInfo: TokoCashPayment
    private let navigator: TokoCashQRPaymentSuccessNavigator
    
    public init(paymentInfo: TokoCashPayment, navigator: TokoCashQRPaymentSuccessNavigator) {
        self.paymentInfo = paymentInfo
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let payment = input.trigger.flatMapLatest {
            return Driver.of(self.paymentInfo)
        }
        
        let merchantName = payment.map { payment -> String in
            return payment.merchantName ?? ""
        }
        
        let amount = payment.map { payment -> String in
            return NumberFormatter.idr().string(from: NSNumber(value: payment.amount ?? 0)) ?? ""
        }
        
        let datetime = payment.map { payment -> String in
            return payment.datetime ?? "-"
        }
        
        let transactionId = payment.map { payment -> String in
            return payment.transactionId ?? "-"
        }
        
        let balance = payment.map { payment -> String in
            return NumberFormatter.idr().string(from: NSNumber(value: payment.balance ?? 0)) ?? ""
        }
        
        let backToHome = input.backToHomeTrigger
            .do(onNext: navigator.backToHome)
        
        let help = input.helpTrigger
            .withLatestFrom(transactionId)
            .do(onNext: navigator.toHelp)
        
        return Output(merchantName: merchantName,
                      amount: amount,
                      datetime: datetime,
                      transactionId: transactionId,
                      balance:balance,
                      backToHome: backToHome,
                      help: help)
    }
}
