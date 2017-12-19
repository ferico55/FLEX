//
//  ReactModule.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 15/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class ReactModule: NSObject {
    let name: String
    let props: [String: AnyObject]?

    init(name: String, props: [String: AnyObject]?) {
        self.name = name
        self.props = props
    }
}
