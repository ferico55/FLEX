//
//  TokoCashHistoryData.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class TokoCashHistory: NSObject, Unboxable {
    var header: [TokoCashHistoryHeader]?
    var items: [TokoCashHistoryItems]?
    var nextUri: Bool?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.header = try? unboxer.unbox(keyPath: "header")
        self.items = try? unboxer.unbox(keyPath: "items")
        self.nextUri = try? unboxer.unbox(keyPath: "next_uri")
    }
}

final class TokoCashHistoryHeader: NSObject, Unboxable {
    var name: String?
    var type: String?
    var selected: Bool?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.name = try? unboxer.unbox(keyPath: "name")
        self.type = try? unboxer.unbox(keyPath: "type")
        self.selected = (try? unboxer.unbox(keyPath: "selected")) ?? false
    }
}

final class TokoCashHistoryItems: NSObject, Unboxable {
    var transactionId: String?
    var transactionDetailId: String?
    var transactionType: String?
    var title: String?
    var desc: String?
    var userDesc: String?
    var createdAt: String?
    var transactionInfoId: String?
    var transactionInfoDate: String?
    var amountChanges: String?
    var amountChangesSymbol: String?
    var amount: String?
    var amountPending: String?
    var notes: String?
    var message: String?
    var actions: [TokoCashAction]?
    var processedAt: String?
    var iconURI: String?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.transactionId = try? unboxer.unbox(keyPath: "transaction_id")
        self.transactionDetailId = try? unboxer.unbox(keyPath: "transaction_detail_id")
        self.transactionType = try? unboxer.unbox(keyPath: "transaction_type")
        self.title = try? unboxer.unbox(keyPath: "title")
        self.desc = try? unboxer.unbox(keyPath: "description")
        self.userDesc = try? unboxer.unbox(keyPath: "user_description")
        self.createdAt = try? unboxer.unbox(keyPath: "created_at")
        self.transactionInfoId = try? unboxer.unbox(keyPath: "transaction_info_id")
        self.transactionInfoDate = try? unboxer.unbox(keyPath: "transaction_info_date")
        self.amountChanges = try? unboxer.unbox(keyPath: "amount_changes")
        self.amountChangesSymbol = try? unboxer.unbox(keyPath: "amount_changes_symbol")
        self.amount = try? unboxer.unbox(keyPath: "amount")
        self.amountPending = try? unboxer.unbox(keyPath: "amount_pending")
        self.notes = try? unboxer.unbox(keyPath: "notes")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.actions = try? unboxer.unbox(keyPath: "actions")
        self.processedAt = try? unboxer.unbox(keyPath: "processed_at")
        self.iconURI = try? unboxer.unbox(keyPath: "icon_uri")
    }
}

struct TokoCashAction {
    let title: String?
    let method: String?
    let URL: String?
    let params: [String: String]?
    let name: String?
}

extension TokoCashAction: Unboxable {
    init(unboxer: Unboxer) throws {
        self.title = try? unboxer.unbox(keyPath: "title")
        self.method = try? unboxer.unbox(keyPath: "method")
        self.URL = try? unboxer.unbox(keyPath: "url")
        self.params = try? unboxer.unbox(keyPath: "params")
        self.name = try? unboxer.unbox(keyPath: "name")
    }
}

