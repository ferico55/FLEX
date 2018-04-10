//
//  GeneralEnum.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 28/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

internal enum RequestError : Error {
    case networkError
}

internal class FormError:Error{
    public let message:String
    public init(message:String) {
        self.message = message
    }
}
