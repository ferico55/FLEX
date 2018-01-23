//
//  TokoCashAccountViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashAccountViewModel {
    let account: TokoCashAccount
    let identifier: String
    let authDate: String
    
    init(with account: TokoCashAccount) {
        self.account = account
        self.identifier = account.identifier ?? ""
        self.authDate = account.authDateFmt ?? ""
    }
}
