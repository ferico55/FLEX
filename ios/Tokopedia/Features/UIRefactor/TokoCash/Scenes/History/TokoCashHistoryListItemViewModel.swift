//
//  TokoCashHistoryListItemViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final public class TokoCashHistoryListItemViewModel {
    public let historyItem: TokoCashHistoryItems
    public let iconURI: String
    public let title: String
    public let desc: String
    public let date: String
    public let amount: String
    public let amountColor: UIColor
    
    public init(with historyItem: TokoCashHistoryItems) {
        self.historyItem = historyItem
        self.iconURI = historyItem.iconURI ?? ""
        self.title = historyItem.title ?? ""
        self.desc = historyItem.desc ?? ""
        self.date = historyItem.transactionInfoDate ?? ""
        self.amount = historyItem.amountChanges ?? ""
        
        if historyItem.amountChangesSymbol == "-" {
            self.amountColor = #colorLiteral(red: 0.8349999785, green: 0, blue: 0, alpha: 1)
        }else if historyItem.amountChangesSymbol == "+" {
            self.amountColor = #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        }else {
            self.amountColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6999999881)
        }
    }
}
