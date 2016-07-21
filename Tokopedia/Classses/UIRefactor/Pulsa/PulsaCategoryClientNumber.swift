//
//  PulsaCategoryClientNumber.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaCategoryClientNumber: NSObject {
    var is_shown : Bool = false
    var text : String = ""
    var help : String = ""
    var placeholder: String = ""
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "is_shown"  : "is_shown",
            "text" : "text",
            "help" : "help",
            "placeholder" : "placeholder"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let text = aDecoder.decodeObjectForKey("text") as? String {
            self.text = text
        }
        
        if let placeholder = aDecoder.decodeObjectForKey("placeholder") as? String {
            self.placeholder = placeholder
        }
        
        if let is_shown = aDecoder.decodeObjectForKey("is_shown") as? Bool {
            self.is_shown = is_shown
        }
        
        if let help = aDecoder.decodeObjectForKey("help") as? String {
            self.help = help
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(is_shown, forKey: "is_shown")
        aCoder.encodeObject(text, forKey: "text")
        aCoder.encodeObject(help, forKey: "help")
        aCoder.encodeObject(placeholder, forKey: "placeholder")
    }
}
