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
    
    internal func TKPMeUrl() -> URL? {
        var trueURL = "https://tkp.me/r?url=" + self.absoluteString.replacingOccurrences(of: "*", with: ".")
        if let host = self.host, host.contains("tokopedia.com") {
            trueURL = self.absoluteString
        }
        
        return URL(string: trueURL)
    }

}
