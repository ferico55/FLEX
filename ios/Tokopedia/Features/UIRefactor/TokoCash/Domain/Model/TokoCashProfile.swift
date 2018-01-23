//
//  TokoCashProfile.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashProfile {
    let code: String?
    let mobile: String?
    let userId: String?
    let email: String?
    let name: String?
    let accountStatus: String?
    let accountStatusCode: String?
    let accountActivatedAt: String?
    var accountList: [TokoCashAccount]?
}

extension TokoCashProfile: Unboxable {
    init(unboxer: Unboxer) throws {
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

struct TokoCashAccount {
    let clientId: String?
    let clientName: String?
    let identifier: String?
    let identifierType: String?
    let imgURL: String?
    let authDate: String?
    let authDateFmt: String?
    let refreshToken: String?
}

extension TokoCashAccount: Unboxable {
    init(unboxer: Unboxer) throws {
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
