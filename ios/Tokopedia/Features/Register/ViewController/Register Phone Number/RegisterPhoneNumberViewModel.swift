//
//  RegisterPhoneNumberViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 20/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Branch
import Foundation
import Moya
import RxCocoa
import RxSwift
import SwiftyJSON

public final class RegisterPhoneNumberViewModel: ViewModelType {
    
    public struct Input {
        public let phoneNumber: Driver<String>
        public let registerTrigger: Driver<Void>
        public let doSendOtpTrigger: Driver<Void>
        public let doLoginTrigger: Driver<Void>
        public let doRegisterTrigger: Driver<(otpType: CentralizedOTPType, otpResult: COTPResponse)>
    }
    
    public struct Output {
        public let isValidPhoneNumber: Driver<Bool>
        public let descString: Driver<String>
        public let activityIndicator: Driver<Bool>
        public let isUserExist: Driver<String>
        public let login: Driver<TokoCashLoginSendOTPResponse>
        public let isNewUser: Driver<String>
        public let successSendOTP: Driver<(modeDetail: ModeListDetail, accountInfo: AccountInfo)>
        public let register: Driver<Login>
        public let failedMessage: Driver<[String]>
        public let cursorColor: Driver<UIColor>
        public let validationTextColor: Driver<UIColor>
        public let validationColor: Driver<UIColor>
        public let buttonBackgroundColor: Driver<UIColor>
    }
    
    public func transform(input: Input) -> Output {
        
        let isEmpty = input.phoneNumber.map { phoneNumber -> Bool in
            return phoneNumber.isEmpty
        }
        
        let isPhoneNumberGreater = input.phoneNumber.map { phoneNumber -> Bool in
            guard phoneNumber.count >= 8 else { return false }
            return true
        }
        
        let isPhoneNumberLess = input.phoneNumber.map { phoneNumber -> Bool in
            guard phoneNumber.count <= 15 else { return false }
            return true
        }
        
        let isValidPhoneNumber = Driver.combineLatest(isEmpty, isPhoneNumberLess, isPhoneNumberGreater) { isEmpty, isGreater, isLess -> Bool in
            return !isEmpty && isGreater && isLess
        }
        
        let descString = Driver.combineLatest(isValidPhoneNumber, isEmpty, isPhoneNumberLess, isPhoneNumberGreater) { isValid, isEmpty, isLess, isGreater -> String in
            
            if !isEmpty && !isValid {
                if !isGreater {
                    return "Nomor ponsel terlalu pendek, minimum 8 angka"
                } else if !isLess {
                    return "Nomor terlalu panjang, maksimum 15 angka"
                }
            }
            return "Kami akan mengirimkan SMS kode verifikasi"
        }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let msisdnResponse = input.registerTrigger.withLatestFrom(input.phoneNumber).flatMapLatest { phoneNumber -> Driver<MsisdnResponse> in
            return UserRequest.requestMsisdnRegisterCheck(phone: phoneNumber)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let msisdnErrorMessage = msisdnResponse.flatMapLatest { response -> Driver<[String]> in
            guard let errorMessage = response.messageError, errorMessage.count > 0 else {
                return Driver.empty()
            }
            return Driver.just(errorMessage)
        }
        
        let modeDetail = msisdnResponse.flatMapLatest { response -> Driver<ModeListDetail> in
            let modeDetail = ModeListDetail(modeCode: 1, modeText: "sms",
                                            otpListText: "",
                                            afterOtpListText: "Kode verifikasi telah dikirimkan melalui SMS ke \(response.numberView ?? "").",
                                            afterOtpListHtml: "Kode verifikasi telah dikirimkan melalui SMS ke <b>\(response.numberView ?? "")</b>.",
                                            otpListImgUrl: "http://ecs7.tokopedia.net/img/otp/sms-green@2x.png")
            return Driver.just(modeDetail)
        }
        
        let isUserExist = msisdnResponse.flatMapLatest { response -> Driver<String> in
            guard let isExist = response.isExist, isExist, let phoneView = response.numberView else { return Driver.empty() }
            return Driver.just(phoneView)
        }
        
        let checkPhoneNumberTokoCashResponse = input.doLoginTrigger.withLatestFrom(input.phoneNumber)
            .flatMapLatest { phoneNumber -> Driver<TokoCashLoginSendOTPResponse> in
                return WalletService.checkPhoneNumberTokoCash(phoneNumber: phoneNumber)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let login = checkPhoneNumberTokoCashResponse.flatMapLatest { response -> Driver<TokoCashLoginSendOTPResponse> in
            guard response.code == "200000" else {
                return Driver.empty()
            }
            return Driver.just(response)
        }
        
        let loginErrorMessage = checkPhoneNumberTokoCashResponse.flatMapLatest { response -> Driver<[String]> in
            guard response.code != "200000" else {
                return Driver.empty()
            }
            
            if response.code == "412556" {
                return Driver.just(["Anda sudah 3 kali melakukan pengiriman OTP, silakan coba lagi dalam 60 menit"])
            } else {
                return Driver.just(["Terjadi kesalahan pada server, silakan coba kembali"])
            }
        }
        
        let isNewUser = msisdnResponse.flatMapLatest { response -> Driver<String> in
            guard let isExist = response.isExist, !isExist, let phoneView = response.numberView else { return Driver.empty() }
            return Driver.just(phoneView)
        }
        
        let otpParameter = Driver.combineLatest(input.phoneNumber, modeDetail)
        let otpResponse = input.doSendOtpTrigger.withLatestFrom(otpParameter)
            .flatMapLatest { parameter -> Driver<COTPResponse> in
                let (phoneNumber, modeDetail) = parameter
                return AccountProvider().request(.requestCentralizedOtp(otpType: .registerPhoneNumber, modeDetail: modeDetail, phoneNumber: phoneNumber, userId: ""))
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .mapJSON()
                    .map { response -> COTPResponse in
                        let response = JSON(response)
                        return COTPResponse(json: response)
                    }.asDriverOnErrorJustComplete()
            }
        
        let successSendOTP = otpResponse.filter { response -> Bool in
            guard let errorMessage = response.messageError, errorMessage.count > 0 else {
                return true
            }
            return false
        }.withLatestFrom(otpParameter) { _, parameter -> (modeDetail: ModeListDetail, accountInfo: AccountInfo) in
            let (phoneNumber, modeDetail) = parameter
            let accountInfo = AccountInfo()
            accountInfo.userId = ""
            accountInfo.phoneNumber = phoneNumber
            return (modeDetail: modeDetail, accountInfo: accountInfo)
        }
        
        let failedSendOTP = otpResponse.flatMapLatest { response -> Driver<[String]> in
            guard let errorMessage = response.messageError, errorMessage.count > 0 else {
                return Driver.empty()
            }
            return Driver.just(errorMessage)
        }
        
        let registerResponse = input.doRegisterTrigger.withLatestFrom(input.phoneNumber)
            .flatMapLatest { phoneNumber -> Driver<RegisterPhoneNumberResponse> in
                return AccountProvider().request(.registerPhoneNumber(phone: phoneNumber))
                    .map(to: RegisterPhoneNumberResponse.self)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let register = registerResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, Login> in
            guard let userId = response.data?.uID, let authToken = response.data?.tokenInfo else { return Driver.empty() }
            return UserRequest.doLogin(token: authToken, userID: userId)
                .trackActivity(activityIndicator)
                .trackError(errorTracker)
                .asDriverOnErrorJustComplete()
        }.do(onNext: { [weak self] login in
            self?.registerSuccess(login: login)
        })
        
        let registerErrorMessage = registerResponse.flatMapLatest { response -> Driver<[String]> in
            guard let errorMessage = response.messageError, errorMessage.count > 0 else {
                return Driver.empty()
            }
            return Driver.just(errorMessage)
        }
        
        // error message
        let errorLocalization = errorTracker.flatMapLatest { error -> Driver<[String]> in
            guard let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError else { return Driver.empty() }
            if responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            } else {
                return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
            }
        }
        
        let failedMessage = Driver.merge(msisdnErrorMessage, loginErrorMessage, failedSendOTP, registerErrorMessage, errorLocalization)
        
        let cursorColor = Driver.combineLatest(isValidPhoneNumber, isEmpty) { isValid, isEmpty -> UIColor in
            if isEmpty || isValid {
                return #colorLiteral(red: 0.04977724701, green: 0.6847406626, blue: 0.3139206171, alpha: 1)
            }
            return #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        }
        
        let validationTextColor = Driver.combineLatest(isValidPhoneNumber, isEmpty) { isValid, isEmpty -> UIColor in
            guard !isEmpty else { return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38) }
            return isValid ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38) : #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        }
        
        let validationColor = Driver.combineLatest(isValidPhoneNumber, isEmpty) { isValid, isEmpty -> UIColor in
            guard !isEmpty else { return #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) }
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8352941176, green: 0, blue: 0, alpha: 1)
        }
        
        let buttonBackgroundColor = isValidPhoneNumber.map { isValid -> UIColor in
            return isValid ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
        }
        
        return Output(isValidPhoneNumber: isValidPhoneNumber,
                      descString: descString,
                      activityIndicator: activityIndicator.asDriver(),
                      isUserExist: isUserExist,
                      login: login,
                      isNewUser: isNewUser,
                      successSendOTP: successSendOTP,
                      register: register,
                      failedMessage: failedMessage,
                      cursorColor: cursorColor,
                      validationTextColor: validationTextColor,
                      validationColor: validationColor,
                      buttonBackgroundColor: buttonBackgroundColor)
    }
    
    private func registerSuccess(login: Login) {
        LoginAnalytics().trackMoEngageEvent(with: login)
        let storageManager = SecureStorageManager()
        if !storageManager.storeLoginInformation(login.result) {
            return
        }
        
        AnalyticsManager.trackLogin(login)
        Branch.getInstance().setIdentity(UserAuthentificationManager().getUserId())
        NotificationCenter.default.post(name: NSNotification.Name(TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(UPDATE_TABBAR), object: nil, userInfo: nil)
        
        let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self)
        if let manager = tabManager as? ReactEventManager {
            manager.sendLoginEvent(UserAuthentificationManager().getUserLoginData())
        }
    }
}
