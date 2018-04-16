//
//  EmailOTPViewModel.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

public final class EmailOTPViewModel: NSObject, ViewModelType {
    private let email: String
    private var timer: Int = 90
    private let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    private let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    
    public init(_ email: String) {
        self.email = email
    }
    
    public struct Input {
        public let hasEnteredOTPtrigger: Driver<Bool>
        public let valueOTPtrigger: Driver<String>
        public let startCountDownTrigger: Driver<Void>
        public let verifyTrigger: Driver<Void>
        public let resendTrigger: Driver<Void>
        public let clearTrigger: Driver<Void>
    }
    
    public struct Output {
        public let subTitleLabel: Driver<String>
        public let verifyButtonIsEnabled: Driver<Bool>
        public let verifyButtonBackgroundColor: Driver<UIColor>
        public let isSuccessVerifyOTP: Driver<Void>
        public let isSuccessResend: Driver<String>
        public let verifyOTPActivityIndicator: Driver<Bool>
        public let resendActivityIndicator: Driver<Bool>
        public let messageErrors: Driver<[String]>
        public let failedVerifyOTPError: Driver<String>
        public let showStackSuccessBorder: Driver<Void>
        public let showStackErrorBorder: Driver<Void>
        public let countDownStart: Driver<Void>
        public let countDownTick: Driver<NSMutableAttributedString>
        public let countDownStop: Driver<NSMutableAttributedString>
        public let hideClearButton: Driver<Bool>
        public let clearOTP: Driver<Void>
    }
    
    public func transform(input: Input) -> Output {
        let subTitleLabel = Driver.just("Kode verifikasi telah dikirimkan melalui email ke \(self.email)")
        
        let verifyButtonIsEnabled = input.hasEnteredOTPtrigger.map { isFullyEntered -> Bool in
            return isFullyEntered
        }.startWith(false)
        
        let verifyButtonBackgroundColor = verifyButtonIsEnabled.map { isEnabled -> UIColor in
            return isEnabled ? #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1) : #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        }
        
        let verifyOTPValue = input.valueOTPtrigger.map { code -> String in
            return code
        }
        
        let verifyOTPActivityIndicator = ActivityIndicator()
        let verifyOTPErrorTracker = ErrorTracker()
        let verifyOTPResponse = input.verifyTrigger.withLatestFrom(verifyOTPValue)
            .flatMapLatest { uniqueCode -> Driver<UpdateProfileResponse> in
                return SettingUserProfileRequest.requestSubmitProfileUpdate(userId: UserAuthentificationManager().getUserId() ?? "", email: self.email, uniqueCode: uniqueCode)
                    .trackActivity(verifyOTPActivityIndicator)
                    .trackError(verifyOTPErrorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let isSuccessVerifyOTP = verifyOTPResponse.flatMapLatest { response -> Driver<Void> in
            guard let success = response.isSuccess, success == true else {
                return Driver.empty()
            }
            
            if let reactEventManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
                reactEventManager.sendProfileEditedEvent()
            }
            
            return Driver.just()
        }
        
        let verifyOTPError = verifyOTPErrorTracker.flatMapLatest { error -> Driver<[String]> in
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            }
            return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
        }
        
        let verifyOTPErrorFromResponse = verifyOTPResponse.flatMapLatest { response -> Driver<String> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs[0])
            }
            return Driver.empty()
        }
        
        let failedVerifyOTPError = Driver.merge(verifyButtonIsEnabled.map { _ -> String in "" }, verifyOTPErrorFromResponse)
        
        let showStackErrorBorder = failedVerifyOTPError.filter { errorString -> Bool in
            return !errorString.isEmpty
        }.mapToVoid()
        
        let showStackSuccessBorder = input.hasEnteredOTPtrigger.filter { isFullyEntered -> Bool in
            return isFullyEntered
        }.mapToVoid()
        
        let hideClearButton = failedVerifyOTPError.map { errorString -> Bool in
            guard errorString.isEmpty else { return false }
            return true
        }
        
        let timerTickSubject = PublishSubject<Int>()
        let timerStopSubject = PublishSubject<NSMutableAttributedString>()
        let countDownStart = input.startCountDownTrigger.flatMapLatest { [unowned self] _ -> Driver<Void> in
            
            timerTickSubject.onNext(0)
            
            Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .takeWhile({ num -> Bool in
                    num + 1 < self.timer
                })
                .do(onNext: { num in
                    timerTickSubject.onNext(num + 1)
                }, onError: { _ in
                    print("error")
                }, onCompleted: {
                    timerStopSubject.onNext(self.showCompleteText())
                })
                .subscribe()
                .addDisposableTo(self.rx_disposeBag)
            
            return Driver.just()
        }
        
        let countDownTick = timerTickSubject.map { [unowned self] num -> NSMutableAttributedString in
            return self.showCountdownText(resendTimer: self.timer - num)
        }
        
        let resendActivityIndicator = ActivityIndicator()
        let resendErrorTracker = ErrorTracker()
        let sendVerificationCodeResponse = input.resendTrigger.flatMapLatest { [unowned self] _ -> Driver<EmailVerificationCodeResponse> in
            return SettingUserProfileRequest.requestSendEmailVerificationCode(email: self.email)
                .trackActivity(resendActivityIndicator)
                .trackError(resendErrorTracker)
                .asDriverOnErrorJustComplete()
        }
        
        let resendError = resendErrorTracker.flatMapLatest { error -> Driver<[String]> in
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                return Driver.just(["Tidak ada koneksi internet."])
            }
            return Driver.just(["Terjadi kendala pada server. Silahkan coba beberapa saat lagi."])
        }
        
        let isSuccessResend = sendVerificationCodeResponse.flatMapLatest { [unowned self] response -> Driver<String> in
            guard response.isSuccess == true else {
                return Driver.empty()
            }
            return Driver.just(self.email)
        }
        
        let isFailedSendEmailVerificationCode = sendVerificationCodeResponse.flatMapLatest { response -> Driver<[String]> in
            if let errorMsgs = response.messageError, errorMsgs.count > 0 {
                return Driver.just(errorMsgs)
            }
            return Driver.empty()
        }
        
        return Output(subTitleLabel: subTitleLabel,
                      verifyButtonIsEnabled: verifyButtonIsEnabled,
                      verifyButtonBackgroundColor: verifyButtonBackgroundColor,
                      isSuccessVerifyOTP: isSuccessVerifyOTP,
                      isSuccessResend: isSuccessResend,
                      verifyOTPActivityIndicator: verifyOTPActivityIndicator.asDriver(),
                      resendActivityIndicator: resendActivityIndicator.asDriver(),
                      messageErrors: Driver.merge(verifyOTPError, resendError, isFailedSendEmailVerificationCode),
                      failedVerifyOTPError: failedVerifyOTPError,
                      showStackSuccessBorder: showStackSuccessBorder,
                      showStackErrorBorder: showStackErrorBorder,
                      countDownStart: countDownStart,
                      countDownTick: countDownTick.asDriverOnErrorJustComplete(),
                      countDownStop: timerStopSubject.asDriverOnErrorJustComplete(),
                      hideClearButton: hideClearButton,
                      clearOTP: input.clearTrigger)
    }
    
    private func showCountdownText(resendTimer: Int) -> NSMutableAttributedString {
        let combination = NSMutableAttributedString()
        let partOne = NSMutableAttributedString(string: "Mohon tunggu dalam ", attributes: regularAttributes)
        let partTwo = NSMutableAttributedString(string: "\(resendTimer) detik ", attributes: boldAttributes)
        let partThree = NSMutableAttributedString(string: "untuk kirim ulang", attributes: regularAttributes)
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        
        return combination
    }
    
    private func showCompleteText() -> NSMutableAttributedString {
        let combination = NSMutableAttributedString()
        let clickAbleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpGreen()]
        let partOne = NSMutableAttributedString(string: "Tidak menerima kode? ", attributes: regularAttributes)
        let partTwo = NSMutableAttributedString(string: "Kirim ulang", attributes: clickAbleAttributes)
        
        // MARK: Set clickable
        partTwo.addAttribute(NSLinkAttributeName, value: "resend://", range: (partTwo.string as NSString).range(of: "Kirim ulang"))
        
        combination.append(partOne)
        combination.append(partTwo)
        
        return combination
    }
    
}
