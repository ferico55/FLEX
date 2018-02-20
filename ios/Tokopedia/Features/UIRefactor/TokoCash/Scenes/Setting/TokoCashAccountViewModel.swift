//
//  TokoCashAccountViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final public class TokoCashAccountViewModel {
    public let account: TokoCashAccount
    public let identifier: String
    public let authDate: String
    
    public init(with account: TokoCashAccount) {
        self.account = account
        self.identifier = account.identifier ?? ""
        self.authDate = account.authDateFmt ?? ""
    }
}
