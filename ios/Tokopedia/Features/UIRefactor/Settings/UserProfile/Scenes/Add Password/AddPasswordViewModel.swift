//
//  AddPasswordViewModel.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/28/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

@objc public final class AddPasswordViewModel: NSObject, ViewModelType {
    
    public struct Input {
        public let passwordTrigger: Driver<String>
        public let revealTrigger: Driver<Void>
        public let submitTrigger: Driver<Void>
    }
    
    public struct Output {
        public let isValid: Driver<Bool>
        public let revealPassword: Driver<Void>
        public let isSuccess: Driver<Void>
        public let activityIndicator: Driver<Bool>
        public let messageErrors: Driver<[String]>
        public let cursorColor: Driver<UIColor>
        public let underLineColor: Driver<UIColor>
        public let buttonBackgroundColor: Driver<UIColor>
    }
    
    public func transform(input: Input) -> Output {
        
        let isEmpty = input.passwordTrigger.map { passString -> Bool in
            return passString.isEmpty
        }
        
        let isValid = input.passwordTrigger.map { passString -> Bool in
            return passString.count >= 6
        }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let updateProfileResponse = input.submitTrigger.withLatestFrom(input.passwordTrigger)
            .flatMapLatest { pass -> Driver<UpdateProfileResponse> in
                return SettingUserProfileRequest
                    .requestSubmitProfileUpdate(userId: UserAuthentificationManager().getUserId() ?? "", password: pass)
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
            .withLatestFrom(input.passwordTrigger)
            .mapToVoid()
        
        let error = errorTracker.flatMapLatest { error -> Driver<[String]> in
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            }
            return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
        }
        
        let isFailed = updateProfileResponse.flatMapLatest { response -> Driver<[String]> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs)
            }
            return Driver.empty()
        }
        
        let cursorColor = isEmpty.map { isEmpty -> UIColor in
            return #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1)
        }
        
        let underLineColor = isValid.map { isValid -> UIColor in
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        let buttonBackgroundColor = isValid.map { isValid -> UIColor in
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        return Output(isValid: isValid,
                      revealPassword: input.revealTrigger,
                      isSuccess: isSuccess,
                      activityIndicator: activityIndicator.asDriver(),
                      messageErrors: Driver.merge(error, isFailed),
                      cursorColor: cursorColor,
                      underLineColor: underLineColor,
                      buttonBackgroundColor: buttonBackgroundColor)
    }
}
