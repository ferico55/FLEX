//
//  TokoCashHistoryData.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashHistoryResponse {
    public let code: String?
    public let message: String?
    public let errors: String?
    public let config: String?
    public let data: TokoCashHistory?
}

extension TokoCashHistoryResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

final public class TokoCashHistory: NSObject, Unboxable {
    public var header: [TokoCashHistoryHeader]?
    public var items: [TokoCashHistoryItems]?
    public var nextUri: Bool?
    
    convenience required public init(unboxer:Unboxer) throws {
        self.init()
        self.header = try? unboxer.unbox(keyPath: "header")
        self.items = try? unboxer.unbox(keyPath: "items")
        self.nextUri = try? unboxer.unbox(keyPath: "next_uri")
    }
}

final public class TokoCashHistoryHeader: NSObject, Unboxable {
    public var name: String?
    public var type: String?
    public var selected: Bool?
    
    convenience required public init(unboxer:Unboxer) throws {
        self.init()
        self.name = try? unboxer.unbox(keyPath: "name")
        self.type = try? unboxer.unbox(keyPath: "type")
        self.selected = (try? unboxer.unbox(keyPath: "selected")) ?? false
    }
}

final public class TokoCashHistoryItems: NSObject, Unboxable {
    public var transactionId: String?
    public var transactionDetailId: String?
    public var transactionType: String?
    public var title: String?
    public var desc: String?
    public var userDesc: String?
    public var createdAt: String?
    public var transactionInfoId: String?
    public var transactionInfoDate: String?
    public var amountChanges: String?
    public var amountChangesSymbol: String?
    public var amount: String?
    public var amountPending: String?
    public var notes: String?
    public var message: String?
    public var actions: [TokoCashAction]?
    public var processedAt: String?
    public var iconURI: String?
    
    convenience required public init(unboxer:Unboxer) throws {
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

public struct TokoCashAction {
    public let title: String?
    public let method: String?
    public let URL: String?
    public let params: [String: String]?
    public let name: String?
}

extension TokoCashAction: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.title = try? unboxer.unbox(keyPath: "title")
        self.method = try? unboxer.unbox(keyPath: "method")
        self.URL = try? unboxer.unbox(keyPath: "url")
        self.params = try? unboxer.unbox(keyPath: "params")
        self.name = try? unboxer.unbox(keyPath: "name")
    }
}

