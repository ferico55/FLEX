//
//  PaymentActionResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Unbox

final public class PaymentActionResponse: Unboxable {

    public var success = false
    public var message: String?
    public var urlString: String?
    public var parameterString: String?

    public init(success: Bool, message: String?, urlString: String?, parameterString: String?) {
        self.success = success
        self.message = message
        self.urlString = urlString
        self.parameterString = parameterString
    }

    convenience public init(unboxer: Unboxer) throws {
        self.init(
            success: try unboxer.unbox(key: "success"),
            message: unboxer.unbox(key: "message"),
            urlString: unboxer.unbox(key: "url"),
            parameterString: unboxer.unbox(key: "param_encode")
            
        )
    }
}
