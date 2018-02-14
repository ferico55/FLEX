//
//  URLExtension.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/31/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

extension URL {
    
    internal func absoluteStringByTrimmingQuery() -> String? {
        if let urlComponents = NSURLComponents(url: self, resolvingAgainstBaseURL: false) {
            urlComponents.query = nil
            return urlComponents.string
        }
        
        return nil
    }

}
