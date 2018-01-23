//
//  TokoCashQRPaymentViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashQRPaymentViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let amount: Driver<String>
        let notes: Driver<String>
        let paymentTrigger: Driver<Void>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let balance: Driver<String>
        let name: Driver<String>
        let phoneNumber: Driver<String>
        let isHiddenPhoneNumber: Driver<Bool>
        let amount: Driver<String>
        let enableAmount: Driver<Bool>
        let validationAmountColor: Driver<UIColor>
        let validationLineColor: Driver<UIColor>
        let disableButton: Driver<Bool>
        let backgroundButtonColor: Driver<UIColor>
        let paymentActivityIndicator: Driver<Bool>
        let paymentSuccess: Driver<TokoCashPayment>
        let paymentFailed: Driver<Void>
    }
    
    private let QRInfo: TokoCashQRInfo
    private let navigator: TokoCashQRPaymentNavigator
    
    init(QRInfo: TokoCashQRInfo, navigator: TokoCashQRPaymentNavigator) {
        self.QRInfo = QRInfo
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let balanceResponse = input.trigger.flatMapLatest {
            return TokoCashUseCase.requestBalance()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let rawBalance = balanceResponse.map { response -> Int in
            return response.data?.rawBalance ?? 0
        }
        
        let balance = balanceResponse.map { response -> String in
            return "TokoCash Balance: \(response.data?.balance ?? "")"
            }.startWith("")
        
        let QRInfo = input.trigger.flatMapLatest {
            return Driver.of(self.QRInfo)
        }
        
        let name = QRInfo.map { QRInfo -> String in
            return QRInfo.name ?? ""
        }
        
        let phoneNumber = QRInfo.map { QRInfo -> String in
            return QRInfo.phoneNumber ?? ""
        }
        
        let isHiddenPhoneNumber = phoneNumber.map { phoneNumber -> Bool in
            return phoneNumber.isEmpty
        }
        
        let enableAmount = QRInfo.map { QRInfo -> Bool in
            return QRInfo.amount == 0
        }
       
        let inputAmount = input.amount.map { amountInString -> Int in
            let amount = amountInString.replacingOccurrences(of: ".", with: "")
            guard !amount.isEmpty else { return 0 }
            return Int(amount) ?? 0
        }
        
        let rawAmount = Driver.merge( QRInfo.map { QRInfo in return QRInfo.amount ?? 0 }, inputAmount)
        
        let amount = rawAmount.map { amount -> String in
            guard amount > 0 else { return "" }
            return NumberFormatter.idrFormatterWithoutCurency().string(from: NSNumber(value: amount)) ?? "0"
        }
        
        let isValidAmount = Driver.combineLatest(amount, rawAmount, rawBalance) { (amount, rawAmount, balance) -> Bool in
            guard !amount.isEmpty else { return false }
            return rawAmount <= balance
        }
        
        let validationAmountColor = isValidAmount.withLatestFrom(amount) { (isValid, amount) -> UIColor in
            guard !amount.isEmpty else { return UIColor.tpPrimaryBlackText() }
            return isValid ? UIColor.tpPrimaryBlackText() : UIColor.tpRed()
        }
        
        let validationLineColor = Driver.combineLatest(amount, isValidAmount) { (amount, isValid) -> UIColor in
            if amount.isEmpty {
                return UIColor.tpLine()
            }else { return isValid ? UIColor.tpGreen() : UIColor.tpRed() }
        }
        
        let notesParameter = input.notes.map { notes -> String in
            guard !notes.isEmpty, !(notes.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty else { return "Pembayaran ke merchant" }
            return notes
        }
        
        let paymentData = Driver.combineLatest(rawAmount, notesParameter, QRInfo)
        
        let paymentActivityIndicator = ActivityIndicator()
        let paymentErrorTracker = ErrorTracker()
        let payment = input.paymentTrigger.withLatestFrom(paymentData)
            .flatMapLatest { (amount, notes, QRInfo) -> SharedSequence<DriverSharingStrategy, TokoCashPaymentResponse> in
                TokoCashUseCase.requestPayment(amount, notes: notes, merchantIdentifier: QRInfo.merchantIdentifier ?? "")
                    .trackActivity(paymentActivityIndicator)
                    .trackError(paymentErrorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let paymentSuccessData = Driver.combineLatest(QRInfo, rawAmount, payment)
        let paymentSuccess = paymentSuccessData.filter { (QRInfo, amount, response) -> Bool in
            guard let code = response.code, let status = response.data?.status, code == "200000", status == "success" else { return false }
            return true
            }.flatMapLatest{ (QRInfo, amount, response) -> SharedSequence<DriverSharingStrategy, TokoCashPayment> in
                guard var paymentData = response.data else { return Driver.empty() }
                paymentData.merchantName = QRInfo.name
                paymentData.amount = amount
                return Driver.of(paymentData)
            }.do(onNext: navigator.toQRPaymentSuccess)
        
        let paymentFailed =  paymentErrorTracker.mapToVoid().do(onNext: navigator.toQRPaymentFailed)
        
        let disableButton = Driver.merge(isValidAmount.withLatestFrom(amount, resultSelector: { (isValid, amount) -> Bool in
            guard amount.isEmpty else { return !isValid }
            return true
        }), paymentActivityIndicator.asDriver()).map {  isRequest -> Bool in
            return !isRequest
        }
        
        let backgroundButtonColor = disableButton.map { disableButton -> UIColor in
            guard disableButton else { return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0) }
            return UIColor.tpOrange()
        }
        
        return Output(fetching: activityIndicator.asDriver(),
                      balance: balance,
                      name: name,
                      phoneNumber: phoneNumber,
                      isHiddenPhoneNumber: isHiddenPhoneNumber,
                      amount: amount,
                      enableAmount: enableAmount,
                      validationAmountColor: validationAmountColor,
                      validationLineColor: validationLineColor,
                      disableButton: disableButton,
                      backgroundButtonColor: backgroundButtonColor,
                      paymentActivityIndicator: paymentActivityIndicator.asDriver(),
                      paymentSuccess: paymentSuccess,
                      paymentFailed: paymentFailed)
    }
}
