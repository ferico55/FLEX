//
//  TokoCashAccountViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public final class TokoCashAccountViewModel {
    
    public struct Input {
        public let deleteButtonTrigger: Driver<Void>
    }
    
    public struct Output {
        public let identifier: Driver<String>
        public let authDate: Driver<String>
        public let deleteAccount: Driver<TokoCashAccount>
    }
    
    private let account: TokoCashAccount
    
    public init(with account: TokoCashAccount) {
        self.account = account
    }
    
    public func transform(input: Input) -> Output {
        
        let account = Driver.of(self.account)
        
        let identifier = account.map { account -> String in
            return account.identifier ?? ""
        }
        
        let authDate = account.map { account -> String in
            account.authDateFmt ?? ""
        }
        
        let deleteAccount = input.deleteButtonTrigger.withLatestFrom(account) { _, account -> TokoCashAccount in
            return account
        }
        
        return Output(identifier: identifier,
                      authDate: authDate,
                      deleteAccount: deleteAccount)
    }
}
