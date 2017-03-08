//
//  PulsaCategoryClientNumber.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaCategoryClientNumber: NSObject {
    var is_shown : Bool = false
    var text : String = ""
    var help : String = ""
    var placeholder: String = ""
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "is_shown"  : "is_shown",
            "text" : "text",
            "help" : "help",
            "placeholder" : "placeholder"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let text = aDecoder.decodeObject(forKey: "text") as? String {
            self.text = text
        }
        
        if let placeholder = aDecoder.decodeObject(forKey: "placeholder") as? String {
            self.placeholder = placeholder
        }
        
        if let is_shown = aDecoder.decodeObject(forKey: "is_shown") as? Bool {
            self.is_shown = is_shown
        }
        
        if let help = aDecoder.decodeObject(forKey: "help") as? String {
            self.help = help
        }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(is_shown as Any?, forKey: "is_shown")
        aCoder.encode(text as Any?, forKey: "text")
        aCoder.encode(help as Any?, forKey: "help")
        aCoder.encode(placeholder as Any?, forKey: "placeholder")
    }
}
