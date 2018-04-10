//
//  TokoCashWalletHistoryViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashViewModel: ViewModelType {
    
    public struct Input {
        public let didLoadTrigger: Driver<Void>
        public let refreshTrigger: Driver<Void>
        public let nominalTrigger: Driver<Void>
        public let topUpTrigger: Driver<Void>
    }
    
    public struct Output {
        public let fetching: Driver<Bool>
        public let balance: Driver<String>
        public let holdBalance: Driver<String>
        public let totalBalance: Driver<String>
        public let threshold: Driver<String>
        public let holdBalanceView: Driver<Bool>
        public let spendingProgress: Driver<Float>
        public let isTopUpVisible: Driver<Bool>
        public let selectedNominalString: Driver<String>
        public let nominal: Driver<DigitalProduct>
        public let topUp: Driver<String>
        public let topUpActivityIndicator: Driver<Bool>
        public let disableTopUpButton: Driver<Bool>
        public let backgroundButtonColor: Driver<UIColor>
    }
    
    private var topUpVisible: Bool
    private var navigator: TokoCashNavigator
    
    public init(_ topUpVisible: Bool, navigator: TokoCashNavigator) {
        self.topUpVisible = topUpVisible
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let walletStore = input.refreshTrigger.flatMapLatest {
            TokoCashUseCase.requestBalance()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let isTopUpVisible = Driver.merge(Driver.of(self.topUpVisible), walletStore.map({ (walletStore) -> Bool in
            walletStore.data?.action?.visibility != "1"
        })).distinctUntilChanged().map { return !$0 }
        
        let balance = walletStore.map { (walletStore) -> String in
            return walletStore.data?.balance ?? ""
        }.startWith("")
        
        let rawHoldBalance = walletStore.map { (walletStore) -> Int in
            return walletStore.data?.rawHoldBalance ?? 0
        }
        
        let holdBalance = walletStore.map { (walletStore) -> String in
            return walletStore.data?.holdBalance ?? ""
        }
        
        let holdBalanceView = rawHoldBalance.map { holdBalance -> Bool in
            return holdBalance == 0
        }.startWith(true)
        
        let rawTotalBalance = walletStore.map { (walletStore) -> Int in
            return walletStore.data?.rawTotalBalance ?? 0
        }
        
        let totalBalance = walletStore.map { (walletStore) -> String in
            return walletStore.data?.totalBalance ?? ""
        }.startWith("")
        
        let rawThreshold = walletStore.map { (walletStore) -> Int in
            guard let rawThreshold = walletStore.data?.rawThreshold, rawThreshold > 0 else { return 20000000 }
            return rawThreshold
        }
        
        let threshold = rawThreshold.map { (rawThreshold) -> String in
            return "Limit: \(NumberFormatter.idr().string(from: NSNumber(value: rawThreshold)) ?? "")/bulan"
        }.startWith("")
        
        let spendingProgress = Driver.combineLatest(rawTotalBalance, rawThreshold) { spending, threshold -> Float in
            if spending < threshold {
                let progress = Float(spending) / Float(threshold)
                return progress
            }
            return 1.0
        }.startWith(0.0)
        
        let digitalProducts = input.didLoadTrigger.flatMapLatest {
            return DigitalProvider()
                .request(.category("103"))
                .map(to: DigitalForm.self)
                .asDriverOnErrorJustComplete()
        }
        
        let nominalItems = digitalProducts.flatMapLatest { digitalForm -> SharedSequence<DriverSharingStrategy, [DigitalProduct]> in
            guard let products = digitalForm.operators.first?.products else { return Driver.empty() }
            return Driver.of(products)
        }
        
        let nominal = input.nominalTrigger
            .withLatestFrom(nominalItems)
            .flatMapLatest { digitalProducts -> SharedSequence<DriverSharingStrategy, DigitalProduct> in
                let vc = self.navigator.toNominal(nominal: digitalProducts)
                return vc.nominal.asDriverOnErrorJustComplete()
            }
        
        let selectedNominal = Driver.merge(nominalItems.flatMapLatest { digitalProducts -> SharedSequence<DriverSharingStrategy, DigitalProduct> in
            guard let nominal = digitalProducts.first else { return Driver.empty() }
            return Driver.of(nominal)
        }, nominal)
        
        let selectedNominalString = selectedNominal.map { digitalProduct -> String in
            return digitalProduct.priceText
        }.startWith("")
        
        let topUpActivityIndicator = ActivityIndicator()
        let topUperrorTracker = ErrorTracker()
        
        let topUp = input.topUpTrigger.withLatestFrom(selectedNominal)
            .flatMapLatest { (digitalProduct) -> SharedSequence<DriverSharingStrategy, String> in
                return DigitalService()
                    .purchase(categoryId: "103", operatorId: "504", productId: digitalProduct.id, textInputs: [:], instantCheckout: false)
                    .trackActivity(topUpActivityIndicator)
                    .trackError(topUperrorTracker)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: { categoryID in
                self.navigator.toDigitalCart(categoryID)
            })
        
        let disableTopUpButton = topUpActivityIndicator.asDriver().map { isRequest -> Bool in
            return !isRequest
        }
        
        let backgroundButtonColor = disableTopUpButton.map { disableButton -> UIColor in
            guard disableButton else { return #colorLiteral(red: 0.878000021, green: 0.878000021, blue: 0.878000021, alpha: 1) }
            return #colorLiteral(red: 1, green: 0.4790000021, blue: 0.003000000026, alpha: 1)
        }
        
        return Output(fetching: activityIndicator.asDriver(),
                      balance: balance,
                      holdBalance: holdBalance,
                      totalBalance: totalBalance,
                      threshold: threshold,
                      holdBalanceView: holdBalanceView,
                      spendingProgress: spendingProgress,
                      isTopUpVisible: isTopUpVisible,
                      selectedNominalString: selectedNominalString,
                      nominal: nominal,
                      topUp: topUp,
                      topUpActivityIndicator: topUpActivityIndicator.asDriver(),
                      disableTopUpButton: disableTopUpButton, backgroundButtonColor: backgroundButtonColor)
    }
}
