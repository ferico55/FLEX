//
//  AddEmailViewModel.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/23/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

@objc final public class AddEmailViewModel: NSObject, ViewModelType {
    public struct Input {
        public let emailTrigger: Driver<String>
        public let continueTrigger: Driver<Void>
    }
    
    public struct Output {
        public let isValid: Driver<Bool>
        public let isSendVerificationCodeSuccess: Driver<String>
        public let activityIndicator: Driver<Bool>
        public let messageErrors: Driver<[String]>
        public let emailError: Driver<String>
        public let cursorColor: Driver<UIColor>
        public let underLineColor: Driver<UIColor>
        public let infoLabelColor: Driver<UIColor>
        public let buttonBackgroundColor: Driver<UIColor>
    }
    
    public func transform(input: Input) -> Output {
        
        let infoString = input.emailTrigger.asDriver().map { _ -> String in
            return "Kami akan mengirimkan email kode verifikasi"
        }

        let isValid = input.emailTrigger.map { emailString -> Bool in
            return !emailString.isEmpty
        }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let checkEmailResponse = input.continueTrigger.withLatestFrom(input.emailTrigger).flatMapLatest { email -> Driver<EmailCheckResponse> in
            return SettingUserProfileRequest.requestEmailRegisterCheck(email: email)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let isCheckEmailSuccess = checkEmailResponse.flatMapLatest { response -> Driver<Void> in
            guard let exist = response.isExist, let msgError = response.messageError, exist == false, msgError.isEmpty else {
                return Driver.empty()
            }
            return Driver.just()
        }
        
        let sendVerificationCodeResponse = isCheckEmailSuccess.withLatestFrom(input.emailTrigger)
            .flatMapLatest { email -> Driver<EmailVerificationCodeResponse> in
            return SettingUserProfileRequest.requestSendEmailVerificationCode(email: email)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let data = Driver.combineLatest(sendVerificationCodeResponse, input.emailTrigger)
        let isSendVerificationCodeSuccess = sendVerificationCodeResponse.withLatestFrom(data)
            .flatMapLatest { data -> Driver<String> in
            let (response, email) = data
            guard response.isSuccess == true else {
                return Driver.empty()
            }
            return Driver.just(email)
        }
        
        let error = errorTracker.flatMapLatest { error -> Driver<[String]> in
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            }
            return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
        }
        
        let emailAlreadyExistError = checkEmailResponse
            .flatMapLatest { response -> Driver<String> in
                guard let exist = response.isExist, exist == true else {
                    return Driver.empty()
                }
                return Driver.just("Email sudah dipakai")
        }
        
        let isFailedCheckEmail = checkEmailResponse.flatMapLatest { response -> Driver<String> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs.joined(separator: " "))
            }
            return Driver.empty()
        }
        
        let isFailedSendEmailVerificationCode = sendVerificationCodeResponse.flatMapLatest { response -> Driver<[String]> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs)
            }
            return Driver.empty()
        }
        
        let underlineError = Driver.merge(emailAlreadyExistError, isFailedCheckEmail)
        
        let cursorColor = input.emailTrigger.asDriver().map { _ -> UIColor in
            return #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1)
        }
        
        let underlineColor = isValid.map { isValid -> UIColor in
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        let infoLabelColor = isValid.map { isValid -> UIColor in
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38)
        }
        
        let buttonBackgroundColor = isValid.map { isEnabled -> UIColor in
            return isEnabled ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        let errorColor = underlineError.map { _ -> UIColor in
            return #colorLiteral(red: 0.8823529412, green: 0.2941176471, blue: 0.2078431373, alpha: 1)
        }
        
        return Output(isValid: isValid,
                      isSendVerificationCodeSuccess: isSendVerificationCodeSuccess,
                      activityIndicator: activityIndicator.asDriver(),
                      messageErrors: Driver.merge(error, isFailedSendEmailVerificationCode),
                      emailError: Driver.merge(infoString,
                                               emailAlreadyExistError,
                                               isFailedCheckEmail),
                      cursorColor: Driver.merge(cursorColor, errorColor),
                      underLineColor: Driver.merge(underlineColor, errorColor),
                      infoLabelColor: Driver.merge(infoLabelColor, errorColor),
                      buttonBackgroundColor: buttonBackgroundColor)
    }
}

