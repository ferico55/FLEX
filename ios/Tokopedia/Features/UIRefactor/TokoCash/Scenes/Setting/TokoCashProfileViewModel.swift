//
//  TokoCashProfileViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 15/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashProfileViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let selectedIndex: Driver<TokoCashAccount>
    }
    
    public struct Output {
        public let fetching: Driver<Bool>
        public let name: Driver<String>
        public let email: Driver<String>
        public let phoneNumber: Driver<String>
        public let isHiddenAccount: Driver<Bool>
        public let accounts: Driver<[TokoCashAccountViewModel]>
        public let deleteActivityIndicator: Driver<Bool>
        public let successMessage: Driver<String>
    }
    
    private let navigator: TokoCashProfileNavigator
    
    public init(navigator: TokoCashProfileNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let profileResponse = input.trigger.flatMapLatest {
            return TokoCashUseCase.requestProfile()
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let name = profileResponse.map { response -> String in
            return response.data?.name ?? ""
            }.startWith("")
        
        let email = profileResponse.map { response -> String in
            return response.data?.email ?? ""
            }.startWith("")
        
        let phoneNumber = profileResponse.map { response -> String in
            return response.data?.mobile ?? ""
            }.startWith("")
        
        let isHiddenAccount = profileResponse.map { response -> Bool in
            return response.data?.accountList?.count == 0
            }.startWith(true)
        
        let accounts = profileResponse.map { response -> [TokoCashAccount] in
            return response.data?.accountList ?? []
        }
        
        let accountViewModels = accounts.map { $0.map { TokoCashAccountViewModel(with: $0) } }
        
        let deleteActivityIndicator = ActivityIndicator()
        let deleteErrorTracker = ErrorTracker()
        let deleteAccountResponse = input.selectedIndex.flatMap { account in
            return TokoCashUseCase.requestRevokeAccount(revokeToken: account.refreshToken ?? "",
                                                        identifier: account.identifier ?? "",
                                                        identifierType: account.identifierType ?? "")
                .trackActivity(deleteActivityIndicator)
                .trackError(deleteErrorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let successMessage = deleteAccountResponse.filter { response -> Bool in
            return response.code == "200000"
            }.map { response -> String in
                return response.message ?? ""
            }.do(onNext: { _ in
                SecureStorageManager().storeTokoCashToken("")
                self.navigator.toHome()
            })
        
        return Output(fetching: activityIndicator.asDriver(),
                      name: name,
                      email: email,
                      phoneNumber: phoneNumber,
                      isHiddenAccount: isHiddenAccount,
                      accounts: accountViewModels,
                      deleteActivityIndicator: deleteActivityIndicator.asDriver(),
                      successMessage: successMessage)
    }
    
}
