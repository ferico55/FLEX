//
//  TokoCashHistoryDetailViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashHistoryDetailViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let helpTrigger: Driver<Void>
        public let moveToTrigger: Driver<Void>
    }
    
    public struct Output {
        public let icon: Driver<String>
        public let title: Driver<String>
        public let desc: Driver<String>
        public let nominal: Driver<String>
        public let nominalColor: Driver<UIColor>
        public let notes: Driver<String>
        public let transaction: Driver<String>
        public let message: Driver<String>
        public let showMoveToSaldoButton: Driver<Bool>
        public let helpButtonBorderColor: Driver<CGColor>
        public let helpButtonBackgroundColor: Driver<UIColor>
        public let helpButtonTitleColor: Driver<UIColor>
        public let help: Driver<String>
        public let moveToSaldo: Driver<TokoCashHistoryItems>
    }
    
    private let historyItem: TokoCashHistoryItems
    private let navigator: TokoCashHistoryDetailNavigator
    
    public init(historyItem: TokoCashHistoryItems, navigator: TokoCashHistoryDetailNavigator) {
        self.historyItem = historyItem
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let item = input.trigger.flatMapLatest {
            return Driver.of(self.historyItem)
        }
        
        let icon = item.map { (historyItem) -> String in
            return historyItem.iconURI ?? ""
        }
        
        let title = item.map { (historyItem) -> String in
            return historyItem.title ?? ""
        }
        
        let desc = item.map { (historyItem) -> String in
            return historyItem.desc ?? ""
        }
        
        let nominal = item.map { (historyItem) -> String in
            return historyItem.amountChanges ?? ""
        }
        
        let nominalColor = item.map { (historyItem) -> UIColor in
            if historyItem.amountChangesSymbol == "-" {
                return #colorLiteral(red: 0.8349999785, green: 0, blue: 0, alpha: 1)
            } else if historyItem.amountChangesSymbol == "+" {
                return #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
            } else {
                return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6999999881)
            }
        }
        
        let notes = item.map { (historyItem) -> String in
            return historyItem.notes ?? ""
        }
        
        let transaction = item.map { (historyItem) -> String in
            return "\(historyItem.transactionInfoId ?? "") \(historyItem.transactionInfoDate ?? "")"
        }
        
        let message = item.map { (historyItem) -> String in
            return historyItem.message ?? ""
        }
        
        let showMoveToSaldoButton = item.map { historyItem -> Bool in
            guard let actions = historyItem.actions, let _ = actions.index(where: { $0.name == "movetosaldo" }) else { return true }
            return false
        }
        
        let helpButtonBorderColor = showMoveToSaldoButton.map { isHidden -> CGColor in
            return isHidden ? #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1).cgColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1199999973).cgColor
        }
        
        let helpButtonBackgroundColor = showMoveToSaldoButton.map { isHidden -> UIColor in
            return isHidden ? #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        let helpButtonTitleColor =  showMoveToSaldoButton.map { isHidden -> UIColor in
            return isHidden ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3799999952)
        }
        
        let transactionId = item.map { historyItem -> String in
            return historyItem.transactionId ?? ""
        }
        
        let help = input.helpTrigger
            .withLatestFrom(transactionId)
            .do(onNext: navigator.toHelp)
        
        let moveToSaldo = input.moveToTrigger
            .withLatestFrom(item)
            .do(onNext: navigator.toMoveToSaldo)
        
        return Output(icon: icon,
                      title: title,
                      desc: desc,
                      nominal: nominal,
                      nominalColor: nominalColor,
                      notes: notes,
                      transaction: transaction,
                      message: message,
                      showMoveToSaldoButton: showMoveToSaldoButton,
                      helpButtonBorderColor: helpButtonBorderColor,
                      helpButtonBackgroundColor: helpButtonBackgroundColor,
                      helpButtonTitleColor: helpButtonTitleColor,
                      help: help,
                      moveToSaldo: moveToSaldo)
    }
}
