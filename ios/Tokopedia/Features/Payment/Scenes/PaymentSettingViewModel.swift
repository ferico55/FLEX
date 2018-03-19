//
//  PaymentSettingViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

@objc public final class PaymentSettingViewModel: NSObject, ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let selected: Driver<IndexPath>
        public let saveTrigger: Driver<Void>
        public let authenticationSettingTrigger: Driver<Void>
    }
    
    public struct Output {
        public let activityIndicator: Driver<Bool>
        public let desc: Driver<String>
        public let hideDesc: Driver<Bool>
        public let hideCCTableView: Driver<Bool>
        public let creditCard: Driver<[PaymentCCViewModel]>
        public let hideAddButton: Driver<Bool>
        public let selectedCC: Driver<CreditCardData>
        public let saveCC: Driver<Void>
        public let authenticationSetting: Driver<Void>
        public let error: Driver<Error>
    }
    
    private let navigator: PaymentSettingNavigator
    
    public init(navigator: PaymentSettingNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let creditCardResponse = input.trigger.flatMapLatest {
            return PaymentUseCase.requestListCreditCardData()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let creditCard = creditCardResponse.map { response -> [CreditCardData] in
            return response.list ?? [CreditCardData]()
        }
        
        let desc = creditCard.map { creditCard -> String in
            return "Kartu Kredit Tersimpan (\(creditCard.count)/4)"
        }
        
        let hideDesc = creditCard.map { creditCard -> Bool in
            return creditCard.count > 0
        }.startWith(true)
        
        let hideCCTableView = hideDesc.map { (hideDesc) -> Bool in
            return !hideDesc
        }.startWith(true)
        
        let creditCardViewModel = creditCard
            .map { $0.map { PaymentCCViewModel(with: $0) } }
        
        let hideAddButton = Driver.merge(activityIndicator.asDriver().flatMapLatest { isActive -> SharedSequence<DriverSharingStrategy, Bool> in
            isActive ? Driver.of(true) : Driver.empty()
        }, creditCard.map { creditCard -> Bool in
            guard creditCard.count > 0 && creditCard.count < 4 else { return true }
            return false
        }).startWith(true)
        
        let selectedCC = input.selected.withLatestFrom(creditCard) { (indexPath, creditCard) -> CreditCardData in
            return creditCard[indexPath.row]
        }.do(onNext: navigator.toDetailCC)
        
        let saveCC = input.saveTrigger.do(onNext: navigator.toSaveCC)
        
        let authenticationSetting = input.authenticationSettingTrigger.do(onNext: navigator.toAuthenticationSetting)
        
        return Output(activityIndicator: activityIndicator.asDriver(),
                      desc: desc,
                      hideDesc: hideDesc,
                      hideCCTableView: hideCCTableView,
                      creditCard: creditCardViewModel,
                      hideAddButton: hideAddButton,
                      selectedCC: selectedCC,
                      saveCC: saveCC,
                      authenticationSetting: authenticationSetting,
                      error: errorTracker.asDriver())
    }
}
