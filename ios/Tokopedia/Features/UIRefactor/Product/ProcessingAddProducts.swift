//
//  ProcessingAddProducts.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 28/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc public class ProcessingProduct: NSObject {
    public let price: String
    public let name: String
    public let etalase: String
    public let currency: String
    public let failed: Bool
    
    public init(price: String, name: String, etalase: String, currency: String, failed: Bool) {
        self.price = price
        self.name = name
        self.etalase = etalase
        self.currency = currency
        self.failed = failed
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ProcessingProduct else { return false }
        if object.name == self.name && object.price == self.price && object.etalase == self.etalase && object.currency == self.currency {
            return true
        }
        return false
    }
}

@objc public class ProcessingAddProducts: NSObject {
    public var products: [ProcessingProduct]
    
    public static let sharedInstance:ProcessingAddProducts = {
        let instance = ProcessingAddProducts()
        return instance
    } ()
    
    private override init() {
        products = []
    }
}
