//
//  TokoCashQRPaymentSuccessViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashQRPaymentSuccessViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let backToHomeTrigger: Driver<Void>
        let helpTrigger: Driver<Void>
    }
    
    struct Output {
        let merchantName: Driver<String>
        let amount: Driver<String>
        let datetime: Driver<String>
        let transactionId: Driver<String>
        let balance: Driver<String>
        let backToHome: Driver<Void>
        let help: Driver<String>
    }
    
    private let paymentInfo: TokoCashPayment
    private let navigator: TokoCashQRPaymentSuccessNavigator
    
    init(paymentInfo: TokoCashPayment, navigator: TokoCashQRPaymentSuccessNavigator) {
        self.paymentInfo = paymentInfo
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
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
            return payment.transaction_id ?? "-"
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
