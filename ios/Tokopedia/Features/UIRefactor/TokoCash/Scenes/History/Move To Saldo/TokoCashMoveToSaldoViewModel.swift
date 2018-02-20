//
//  TokoCashMoveToSaldoViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashMoveToSaldoViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let cancelTrigger: Driver<Void>
        public let moveToSaldoTrigger: Driver<Void>
    }
    
    public struct Output {
        public let nominal: Driver<String>
        public let disableButton: Driver<Bool>
        public let backgroundButtonColor: Driver<UIColor>
        public let cancel: Driver<Void>
        public let requestActivity: Driver<Bool>
        public let moveToSaldoSuccess: Driver<TokoCashMoveToSaldoResponse>
        public let moveToSaldoFailed: Driver<Void>
    }
    
    private let historyItem: TokoCashHistoryItems
    private let navigator: TokoCashMoveToSaldoNavigator
    
    public init(historyItem: TokoCashHistoryItems, navigator: TokoCashMoveToSaldoNavigator) {
        self.historyItem = historyItem
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
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
            guard disableButton else { return #colorLiteral(red: 0.878000021, green: 0.878000021, blue: 0.878000021, alpha: 1) }
            return #colorLiteral(red: 1, green: 0.4790000021, blue: 0.003000000026, alpha: 1)
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
