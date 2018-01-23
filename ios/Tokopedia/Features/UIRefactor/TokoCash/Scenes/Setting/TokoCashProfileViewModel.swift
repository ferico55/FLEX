//
//  TokoCashProfileViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 15/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashProfileViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let selectedIndex: Driver<Int>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let name: Driver<String>
        let email: Driver<String>
        let phoneNumber: Driver<String>
        let isHiddenAccount: Driver<Bool>
        let accounts: Driver<[TokoCashAccountViewModel]>
        let deleteActivityIndicator: Driver<Bool>
        let successMessage: Driver<String>
    }
    
    private let navigator: TokoCashProfileNavigator
    
    init(navigator: TokoCashProfileNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
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
        
        let selectedAccount = input.selectedIndex.withLatestFrom(accounts) { (index, accounts) -> TokoCashAccount in
            return accounts[index]
        }
        
        let deleteActivityIndicator = ActivityIndicator()
        let deleteErrorTracker = ErrorTracker()
        let deleteAccountResponse = selectedAccount.flatMap { account in
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
