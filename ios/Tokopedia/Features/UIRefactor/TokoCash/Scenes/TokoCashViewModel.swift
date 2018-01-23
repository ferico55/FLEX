//
//  TokoCashWalletHistoryViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let nominal: Driver<DigitalProduct?>
        let nominalTrigger: Driver<Void>
        let topUpTrigger: Driver<Void>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let isTopUpVisible: Driver<Bool>
        let selectedNominalString: Driver<String>
        let balance: Driver<String>
        let holdBalanceView: Driver<Bool>
        let holdBalance: Driver<String>
        let totalBalance: Driver<String>
        let threshold: Driver<String>
        let spendingProgress: Driver<Float>
        let error: Driver<Error>
        let nominal: Driver<[DigitalProduct]>
        let topUp: Driver<String>
        let topUpActivityIndicator: Driver<Bool>
        let disableTopUpButton: Driver<Bool>
        let backgroundButtonColor: Driver<UIColor>
    }
    
    private var topUpVisible: Bool
    private var navigator: TokoCashNavigator
    
    init(_ topUpVisible: Bool, navigator: TokoCashNavigator) {
        self.topUpVisible = topUpVisible
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let walletStore = input.trigger.flatMapLatest {
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
        
        let digitalProducts = input.trigger.flatMapLatest {
            return DigitalProvider()
                .request(.category("103"))
                .map(to: DigitalForm.self)
                .asDriverOnErrorJustComplete()
        }
        
        let nominalItems = digitalProducts.flatMapLatest { digitalForm -> SharedSequence<DriverSharingStrategy, [DigitalProduct]> in
            guard let products = digitalForm.operators.first?.products else { return Driver.empty() }
            return Driver.of(products)
        }
        
        let selectedNominal = Driver.merge(nominalItems.flatMapLatest { digitalProducts -> SharedSequence<DriverSharingStrategy, DigitalProduct?> in
            return Driver.of(digitalProducts.first)
        }, input.nominal)
        
        let selectedNominalString = selectedNominal.map { digitalProduct -> String in
            guard let dp = digitalProduct else { return "" }
            return dp.priceText
        }.startWith("")
        
        let nominal = input.nominalTrigger
            .withLatestFrom(nominalItems)
            .do(onNext: { digitalProduct in
                guard let vc = self.navigator.navigationController.topViewController else { return }
                self.navigator.toNominal(vc as! TokoCashNominalDelegate, nominal: digitalProduct)
            })
        
        let topUpActivityIndicator = ActivityIndicator()
        let topUperrorTracker = ErrorTracker()
        
        let topUp = input.topUpTrigger.withLatestFrom(selectedNominal)
            .flatMapLatest { (digitalProduct) -> SharedSequence<DriverSharingStrategy, String> in
                return DigitalService()
                    .purchase(categoryId: "103", operatorId: "504", productId: digitalProduct?.id ?? "", textInputs: [:], instantCheckout: false)
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
            guard disableButton else { return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0) }
            return UIColor.tpOrange()
        }
        
        return Output(fetching: activityIndicator.asDriver(),
                      isTopUpVisible: isTopUpVisible,
                      selectedNominalString: selectedNominalString,
                      balance: balance,
                      holdBalanceView: holdBalanceView,
                      holdBalance: holdBalance,
                      totalBalance: totalBalance,
                      threshold: threshold,
                      spendingProgress: spendingProgress,
                      error: errorTracker.asDriver(),
                      nominal: nominal,
                      topUp: topUp,
                      topUpActivityIndicator: topUpActivityIndicator.asDriver(),
                      disableTopUpButton: disableTopUpButton,
                      backgroundButtonColor: backgroundButtonColor)
    }
    
}

