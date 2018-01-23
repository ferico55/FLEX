//
//  TokoCashHistoryListItemViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashHistoryListItemViewModel {
    let historyItem: TokoCashHistoryItems
    let iconURI: String
    let title: String
    let desc: String
    let date: String
    let amount: String
    let amountColor: UIColor
    
    init(with historyItem: TokoCashHistoryItems) {
        self.historyItem = historyItem
        self.iconURI = historyItem.iconURI ?? ""
        self.title = historyItem.title ?? ""
        self.desc = historyItem.desc ?? ""
        self.date = historyItem.transactionInfoDate ?? ""
        self.amount = historyItem.amountChanges ?? ""
        
        if historyItem.amountChangesSymbol == "-" {
            self.amountColor = UIColor.tpRed()
        }else if historyItem.amountChangesSymbol == "+" {
            self.amountColor = UIColor.tpGreen()
        }else {
            self.amountColor = UIColor.tpPrimaryBlackText()
        }
    }
}
