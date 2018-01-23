//
//  TokoCashMoveToSaldoViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashMoveToSaldoViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let cancelTrigger: Driver<Void>
        let moveToSaldoTrigger: Driver<Void>
    }
    
    struct Output {
        let nominal: Driver<String>
        let disableButton: Driver<Bool>
        let backgroundButtonColor: Driver<UIColor>
        let cancel: Driver<Void>
        let requestActivity: Driver<Bool>
        let moveToSaldoSuccess: Driver<TokoCashMoveToSaldoResponse>
        let moveToSaldoFailed: Driver<Void>
    }
    
    private let historyItem: TokoCashHistoryItems
    private let navigator: TokoCashMoveToSaldoNavigator
    
    init(historyItem: TokoCashHistoryItems, navigator: TokoCashMoveToSaldoNavigator) {
        self.historyItem = historyItem
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let historyItem = input.trigger.flatMapLatest {
            return Driver.of(self.historyItem)
        }
        
        let nominal = historyItem.map { (historyItem) -> String in
            return historyItem.amountPending ?? ""
        }
        
        let cancel = input.cancelTrigger
            .do(onNext: navigator.toHistory)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let moveToSaldo = input.moveToSaldoTrigger.withLatestFrom(historyItem)
            .flatMapLatest { historyItem -> SharedSequence<DriverSharingStrategy, TokoCashMoveToSaldoResponse> in
                guard let action = historyItem.actions?.first(where: { action -> Bool in action.name == "movetosaldo" ? true : false }) else { return Driver.empty() }
                return TokoCashUseCase.requestAction(URL: action.URL ?? "", method: action.method ?? "", parameter:  action.params ?? [:])
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .map(to: TokoCashMoveToSaldoResponse.self)
                    .asDriverOnErrorJustComplete()
            }
        
        let moveToSaldoSuccess = moveToSaldo
            .do(onNext: navigator.toMoveToSaldoSuccess)
        
        let moveToSaldoFailed = errorTracker.mapToVoid()
            .do(onNext: navigator.toMoveToSaldoFailed)
        
        let disableButton = activityIndicator.map {  fetching -> Bool in
            return !fetching
        }
        
        let backgroundButtonColor = disableButton.map { disableButton -> UIColor in
            guard disableButton else { return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0) }
            return UIColor.tpOrange()
        }
        
        return Output(nominal: nominal,
                      disableButton: disableButton,
                      backgroundButtonColor: backgroundButtonColor,
                      cancel: cancel,
                      requestActivity: activityIndicator.asDriver(),
                      moveToSaldoSuccess: moveToSaldoSuccess,
                      moveToSaldoFailed: moveToSaldoFailed)
    }
    
}
