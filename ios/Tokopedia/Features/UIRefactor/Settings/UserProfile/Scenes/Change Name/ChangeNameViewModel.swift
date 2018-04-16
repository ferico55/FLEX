//
//  ChangeNameViewModel.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/20/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

@objc public final class ChangeNameViewModel: NSObject, ViewModelType {
    
    public struct Input {
        public let userNameTrigger: Driver<String>
        public let alertTrigger: Driver<Void>
        public let submitTrigger: Driver<Void>
    }
    
    public struct Output {
        public let submitButtonIsEnabled: Driver<Bool>
        public let submitButtonBackgroundColor: Driver<UIColor>
        public let descColor: Driver<UIColor>
        public let underLineColor: Driver<UIColor>
        public let cursorColor: Driver<UIColor>
        public let alert: Driver<String>
        public let isSuccess: Driver<Void>
        public let activityIndicator: Driver<Bool>
        public let messageErrors: Driver<String>
        public let errorAlert: Driver<[String]>
    }
    
    public func transform(input: Input) -> Output {
        
        let isEmpty = input.userNameTrigger.map { phoneNumber -> Bool in
            return phoneNumber.isEmpty
        }
        
        let isUserNameGreater = input.userNameTrigger.map { phoneNumber -> Bool in
            return phoneNumber.count >= 3
        }
        
        let isUserNameLess = input.userNameTrigger.map { phoneNumber -> Bool in
            return phoneNumber.count <= 128
        }
        
        let isValidUserName = Driver.combineLatest(isEmpty, isUserNameLess, isUserNameGreater) { isEmpty, isGreater, isLess -> Bool in
            return !isEmpty && isGreater && isLess
        }
        
        let submitButtonBackgroundColor = isValidUserName.map { isEnabled -> UIColor in
            return isEnabled ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        let alert = input.alertTrigger.withLatestFrom(input.userNameTrigger)
            .flatMapLatest { name -> Driver<String> in
                return Driver.just(name)
            }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let updateProfileResponse = input.submitTrigger.withLatestFrom(input.userNameTrigger)
            .flatMapLatest { name -> Driver<UpdateProfileResponse> in
                return SettingUserProfileRequest.requestSubmitProfileUpdate(userId: UserAuthentificationManager().getUserId() ?? "", fullname: name)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let isSuccess = updateProfileResponse
            .filter { response -> Bool in
                guard let success = response.isSuccess, success == true else {
                    return false
                }
                return true
            }
            .withLatestFrom(input.userNameTrigger)
            .do(onNext: { name in
                SecureStorageManager().storeFullName(name)
                guard let reactEventManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
                    return
                }
                reactEventManager.sendProfileEditedEvent()
            })
            .mapToVoid()
        
        let characterCountDesc = Driver.combineLatest(isValidUserName, isUserNameLess, isUserNameGreater) { isValid, isLess, _ -> String in
            guard !isValid, !isLess else { return "Minimum 3 karakter" }
            return "Nama Lengkap terlalu panjang, maksimal 128 karakter."
        }
        
        let isFailed = updateProfileResponse.flatMapLatest { response -> Driver<String> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs.joined(separator: ". "))
            }
            return Driver.empty()
        }
        
        let errorMessage = Driver.merge(characterCountDesc, isFailed)
        
        let isValidUI = Driver.combineLatest(isValidUserName, isUserNameLess, isUserNameGreater) { isValid, isLess, _ -> Bool in
            guard !isValid, !isLess else { return true }
            return false
        }
        
        let invalidColor = isFailed.filter { errorString -> Bool in
            return !errorString.isEmpty
        }.map { _ -> UIColor in
            return #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        }
        
        let descColor = isValidUI.map { isValid -> UIColor in
            guard isValid else { return #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1) }
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38)
        }
        
        let underLineColor = Driver.combineLatest(isEmpty, isValidUserName, isValidUI) { isEmpty, isValidUserName, isValidUI -> UIColor in
            guard !isEmpty else { return #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) }
            if isValidUserName {
                return #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1)
            } else {
                return isValidUI ? #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) : #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
            }
        }
        
        let cursorColor = Driver.combineLatest(isEmpty, isValidUI) { isEmpty, isValid -> UIColor in
            guard !isEmpty else { return #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) }
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        }
        
        let errorAlert = errorTracker.flatMapLatest { error -> Driver<[String]> in
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            }
            return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
        }
        
        return Output(submitButtonIsEnabled: isValidUserName,
                      submitButtonBackgroundColor: submitButtonBackgroundColor,
                      descColor: Driver.merge(descColor, invalidColor),
                      underLineColor: Driver.merge(underLineColor, invalidColor),
                      cursorColor: Driver.merge(cursorColor, invalidColor),
                      alert: alert,
                      isSuccess: isSuccess,
                      activityIndicator: activityIndicator.asDriver(),
                      messageErrors: errorMessage,
                      errorAlert: errorAlert)
    }
}
