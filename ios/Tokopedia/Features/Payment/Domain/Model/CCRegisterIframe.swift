//
//  CCRegisterIframe.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 01/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Foundation
import Unbox

public struct CCRegisterIframeResponse {
    public let success: String?
    public let message: String?
    public let data: CCRegisterIframeData?
}

extension CCRegisterIframeResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.success = try? unboxer.unbox(keyPath: "success")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct CCRegisterIframeData {
    public let ccIframe: CCIframe?
    public let ccIframeEncode: String?
    public let apiInfo: APIInfo?
}

extension CCRegisterIframeData: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.ccIframe = try? unboxer.unbox(keyPath: "cc_iframe")
        self.ccIframeEncode = try? unboxer.unbox(keyPath: "cc_iframe_encode")
        self.apiInfo = try? unboxer.unbox(keyPath: "api_info")
    }
}

public struct CCIframe {
    public let customerName: String?
    public let profileCode: String?
    public let callbackUrl: String?
    public let merchantCode: String?
    public let date: String?
    public let userId: String?
    public let customerEmail: String?
    public let ccToken: String?
    public let signature: String?
    public let ipAddress: String?
}

extension CCIframe: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.customerName = try? unboxer.unbox(keyPath: "customer_name")
        self.profileCode = try? unboxer.unbox(keyPath: "profile_code")
        self.callbackUrl = try? unboxer.unbox(keyPath: "callback_url")
        self.merchantCode = try? unboxer.unbox(keyPath: "merchant_code")
        self.date = try? unboxer.unbox(keyPath: "date")
        self.userId = try? unboxer.unbox(keyPath: "user_id")
        self.customerEmail = try? unboxer.unbox(keyPath: "customer_email")
        self.ccToken = try? unboxer.unbox(keyPath: "cc_token")
        self.signature = try? unboxer.unbox(keyPath: "signature")
        self.ipAddress = try? unboxer.unbox(keyPath: "ip_address")
    }
}

public struct APIInfo {
    public let headers: Dictionary<String, String>?
    public let host: String?
    public let method: String?
}

extension APIInfo: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.headers = try? unboxer.unbox(keyPath: "headers")
        self.host = try? unboxer.unbox(keyPath: "host")
        self.method = try? unboxer.unbox(keyPath: "method")
    }
}

