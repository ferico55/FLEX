//
//  DigitalForm.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

internal final class DigitalBanner: Unboxable {
    internal let id: String
    internal let detail: String
    internal let voucherCode: String
    internal let url: String
    
    internal init(id: String, detail: String, voucherCode: String, url: String) {
        self.id = id
        self.detail = detail
        self.voucherCode = voucherCode
        self.url = url
    }
    
    internal convenience init(unboxer: Unboxer) throws {
        self.init(
            id: try unboxer.unbox(keyPath: "id"),
            detail: try unboxer.unbox(keyPath: "attributes.title"),
            voucherCode: try unboxer.unbox(keyPath: "attributes.promocode"),
            url: try unboxer.unbox(keyPath: "attributes.link")
        )
    }
}

internal struct DigitalForm {
    internal let name: String
    internal let title: String
    internal let operatorLabel: String
    internal let operatorSelectonStyle: DigitalOperatorSelectionStyle
    internal let operators: [DigitalOperator]
    internal let isInstantPaymentAvailable: Bool
    internal let defaultOperator: DigitalOperator?
    internal let banners: [DigitalBanner]
    internal let otherBanners: [DigitalBanner]
}

extension DigitalForm: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(keyPath: "data.attributes.name")
        self.title = try unboxer.unbox(keyPath: "data.attributes.title")
        self.operatorLabel = try unboxer.unbox(keyPath: "data.attributes.operator_label")
        self.operatorSelectonStyle = {
            let operatorStyleString: String = try! unboxer.unbox(keyPath: "data.attributes.operator_style")
            
            switch operatorStyleString {
            case "style_1":
                let textInputFields: DigitalTextInput? = try? unboxer.unbox(keyPath: "data.attributes.fields.0")
                guard let textInput = textInputFields else { return .implicit }
                return .prefixChecking(textInput)
 
            case "style_99": return .implicit
                
            default: return .choice
            }
        }()
        
        let includes = try unboxer.unbox(keyPath: "included") as [[String: Any]]
        let operatorDictionaries = includes.filter {
            "operator" == $0["type"] as! String
        }
        
        let operators = try Unboxer.performCustomUnboxing(array: operatorDictionaries) { unboxer -> DigitalOperator in
            return try DigitalOperator(unboxer: unboxer)
        }
        
        let defaultOperatorId = try unboxer.unbox(keyPath: "data.attributes.default_operator_id") as String
        let defaultOperator = operators.first { $0.operatorID == defaultOperatorId }
        
        let includedBanners = includes.filter {
            "banner" == $0["type"] as! String
        }
        
        let includedOtherBanners = includes.filter {
            "other_banner" == $0["type"] as! String
        }
        
        self.banners = try Unboxer.performCustomUnboxing(array: includedBanners) { unboxer -> DigitalBanner in
            return try DigitalBanner(unboxer: unboxer)
        }
        
        self.otherBanners = try Unboxer.performCustomUnboxing(array: includedOtherBanners) { unboxer -> DigitalBanner in
            return try DigitalBanner(unboxer: unboxer)
        }
        
        self.defaultOperator = defaultOperator
        self.operators = operators
        self.isInstantPaymentAvailable = try unboxer.unbox(keyPath: "data.attributes.instant_checkout")
    }
}
