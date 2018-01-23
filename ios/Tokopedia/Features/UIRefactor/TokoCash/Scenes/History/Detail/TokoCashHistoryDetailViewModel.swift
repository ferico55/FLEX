//
//  TokoCashHistoryDetailViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashHistoryDetailViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let helpTrigger: Driver<Void>
        let moveToTrigger: Driver<Void>
    }
    
    struct Output {
        let icon: Driver<String>
        let title: Driver<String>
        let desc: Driver<String>
        let nominal: Driver<String>
        let nominalColor: Driver<UIColor>
        let notes: Driver<String>
        let transaction: Driver<String>
        let message: Driver<String>
        let showMoveToSaldoButton: Driver<Bool>
        let helpButtonBorderColor: Driver<CGColor>
        let helpButtonBackgroundColor: Driver<UIColor>
        let helpButtonTitleColor: Driver<UIColor>
        let help: Driver<String>
        let moveToSaldo: Driver<TokoCashHistoryItems>
    }
    
    private let historyItem: TokoCashHistoryItems
    private let navigator: TokoCashHistoryDetailNavigator
    
    init(historyItem: TokoCashHistoryItems, navigator: TokoCashHistoryDetailNavigator) {
        self.historyItem = historyItem
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
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
                return UIColor.tpRed()
            } else if historyItem.amountChangesSymbol == "+" {
                return UIColor.tpGreen()
            } else {
                return UIColor.tpPrimaryBlackText()
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
            return isHidden ? UIColor.tpGreen().cgColor : UIColor.tpLine().cgColor
        }
        
        let helpButtonBackgroundColor = showMoveToSaldoButton.map { isHidden -> UIColor in
            return isHidden ? UIColor.tpGreen() : UIColor.white
        }
        
        let helpButtonTitleColor =  showMoveToSaldoButton.map { isHidden -> UIColor in
            return isHidden ? UIColor.white : UIColor.tpDisabledBlackText()
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
