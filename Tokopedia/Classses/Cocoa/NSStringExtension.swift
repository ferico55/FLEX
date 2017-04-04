//
//  NSStringExtension.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension NSString {
    
    func withNumberFormat() ->  NSString {
        let result = NSMutableString(string: self)
        
        var n = self.length
        
        while n - 3 > 0 {
            result.insert(".", at: n - 3)
            n -= 3
        }
        
        return result
    }
}
