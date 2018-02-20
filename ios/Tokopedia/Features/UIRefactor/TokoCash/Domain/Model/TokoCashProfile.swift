//
//  TokoCashProfile.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashProfileResponse {
    public let code: String?
    public let message: String?
    public let errors: String?
    public let config: String?
    public let data: TokoCashProfile?
}

extension TokoCashProfileResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct TokoCashProfile {
    public let code: String?
    public let mobile: String?
    public let userId: String?
    public let email: String?
    public let name: String?
    public let accountStatus: String?
    public let accountStatusCode: String?
    public let accountActivatedAt: String?
    public var accountList: [TokoCashAccount]?
}

extension TokoCashProfile: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.mobile = try? unboxer.unbox(keyPath: "mobile")
        self.userId = try? unboxer.unbox(keyPath: "tokopedia_user_id")
        self.email = try? unboxer.unbox(keyPath: "email")
        self.name = try? unboxer.unbox(keyPath: "name")
        self.accountStatus = try? unboxer.unbox(keyPath: "account_status")
        self.accountStatusCode = try? unboxer.unbox(keyPath: "account_status_code")
        self.accountActivatedAt = try? unboxer.unbox(keyPath: "account_activated_at")
        self.accountList = try? unboxer.unbox(keyPath: "account_list")
    }
}

public struct TokoCashAccount {
    public let clientId: String?
    public let clientName: String?
    public let identifier: String?
    public let identifierType: String?
    public let imgURL: String?
    public let authDate: String?
    public let authDateFmt: String?
    public let refreshToken: String?
}

extension TokoCashAccount: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.clientId = try? unboxer.unbox(keyPath: "client_id")
        self.clientName = try? unboxer.unbox(keyPath: "client_name")
        self.identifier = try? unboxer.unbox(keyPath: "identifier")
        self.identifierType = try? unboxer.unbox(keyPath: "identifier_type")
        self.imgURL = try? unboxer.unbox(keyPath: "img_url")
        self.authDate = try? unboxer.unbox(keyPath: "auth_date")
        self.authDateFmt = try? unboxer.unbox(keyPath: "auth_date_fmt")
        self.refreshToken = try? unboxer.unbox(keyPath: "refresh_token")
    }
}
