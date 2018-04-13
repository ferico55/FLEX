//
//  TokoCashQRCodeViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import AVFoundation
import Branch
import Foundation
import Moya
import RxCocoa
import RxSwift

@objc public class TokoCashQRCodeViewModel: NSObject, ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let triggerviewDidLayoutSubviews: Driver<Void>
        public let triggerDissapear: Driver<Void>
        public let cameraAccessTrigger: Driver<Void>
        public let hasTorch: Driver<Bool>
        public let isTorchAvailable: Driver<Bool>
        public let isTorchActive: Driver<Bool>
        public let identifier: Driver<String>
    }
    
    public struct Output {
        public let needRequestAccess: Driver<Void>
        public let cameraSetting: Driver<Void>
        public let setupCameraView: Driver<Bool>
        public let runCamera: Driver<Bool>
        public let accessCamera: Driver<Bool>
        public let isHidePermission: Driver<Bool>
        public let isHideScanView: Driver<Bool>
        public let isHideFlashButton: Driver<Bool>
        public let flashButtonImage: Driver<UIImage?>
        public let activityIndicator: Driver<Bool>
        public let validationColor: Driver<UIColor>
        public let QRInfo: Driver<TokoCashQRInfo?>
        public let triggerCampaign: Driver<URL>
        public let failedMessage: Driver<[String]>
    }
    
    private let isSetupCamera = Variable(false)
    private let accessCamera = Variable(false)
    
    public func transform(input: Input) -> Output {
        // camera access
        let cameraAccessStatus = Driver.merge(input.cameraAccessTrigger, input.trigger)
            .flatMapLatest { _ -> SharedSequence<DriverSharingStrategy, AVAuthorizationStatus> in
                let access = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                return Driver.of(access)
            }.do(onNext: { cameraAccess in
                self.accessCamera.value = cameraAccess == .authorized ? true : false
            })
        
        let needRequestAccess = input.cameraAccessTrigger.withLatestFrom(cameraAccessStatus)
            .flatMapLatest { cameraAccess -> SharedSequence<DriverSharingStrategy, Void> in
                return cameraAccess == .notDetermined ? Driver.just() : Driver.empty()
            }.do(onNext: { _ in
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { granted in
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.accessCamera.value = granted
                    })
                })
            })
        
        let cameraSetting = input.cameraAccessTrigger.withLatestFrom(cameraAccessStatus)
            .flatMapLatest { cameraAccess -> SharedSequence<DriverSharingStrategy, Void> in
                return cameraAccess == .denied ? Driver.just() : Driver.empty()
            }
        
        let setupCameraView = Driver.combineLatest(accessCamera.asDriver(), isSetupCamera.asDriver(), input.triggerviewDidLayoutSubviews.map { _ -> Bool in
            true
        }).flatMapLatest { accessCamera, isSetupCamera, triggerviewDidLayoutSubviews -> SharedSequence<DriverSharingStrategy, Bool> in
            guard triggerviewDidLayoutSubviews, accessCamera, !isSetupCamera else { return Driver.empty() }
            return Driver.of(true)
        }.do(onNext: { data in
            self.isSetupCamera.value = data
        })
        
        let willAppearRunCamera = input.trigger.withLatestFrom(Driver.combineLatest(accessCamera.asDriver(), isSetupCamera.asDriver())).map { accessCamera, isSetupCamera -> Bool in
            guard accessCamera, isSetupCamera else { return false }
            return true
        }
        
        let dissapearStopCamera = input.triggerDissapear.map { _ -> Bool in
            return false
        }
        
        let runCamera = Driver.merge(setupCameraView, willAppearRunCamera, dissapearStopCamera)
        
        let isHidePermission = runCamera.asDriver().map { accessCamera -> Bool in
            return accessCamera
        }
        
        let isHideScanView = isHidePermission.map { showPermission -> Bool in
            return !showPermission
        }
        
        // Flash
        let isHideFlashButton = Driver.combineLatest(runCamera.asDriver(), input.hasTorch, input.isTorchAvailable) { accessCamera, hasTorch, isTorchAvailable -> Bool in
            guard accessCamera else { return true }
            return !(hasTorch && isTorchAvailable)
        }
        
        let flashButtonImage = input.isTorchActive.map { isActive -> UIImage? in
            guard isActive else { return #imageLiteral(resourceName: "icon_flash_on") }
            return #imageLiteral(resourceName: "icon_flash_off")
        }
        
        // Identifier
        let inputIdentifier = input.identifier
            .distinctUntilChanged()
            .filter { identifier -> Bool in
                return !identifier.isEmpty
            }
        
        let isBranchLink = inputIdentifier.flatMapLatest { identifier -> SharedSequence<DriverSharingStrategy, Bool> in
            let isDeepLink = Branch.getInstance().handleDeepLink(withNewSession: URL(string: identifier))
            return isDeepLink ? Driver.of(true) : Driver.of(false)
        }
        
        let isLogin = PublishSubject<Bool>()
        let isQR = inputIdentifier.map { identifier -> Bool in
            guard identifier.range(of: "tokopedia://w/") != nil else { return false }
            return true
        }.do(onNext: { isQR in
            guard isQR, let topViewController = UIApplication.topViewController() else {
                isLogin.onNext(false)
                return
            }
            AuthenticationService.shared.ensureLoggedInFromViewController(topViewController, onSuccess: {
                let userManager = UserAuthentificationManager()
                if userManager.isLogin {
                    isLogin.onNext(true)
                }
            })
            
        })
        
        let isTc = inputIdentifier.map { identifier -> Bool in
            guard identifier.range(of: "tokopedia://tc/") != nil else { return false }
            return true
        }
        
        let inValidQRCode = Driver.zip(isBranchLink, isQR, isTc)
            .flatMapLatest { (isBranchLink, isQR, isTc) -> SharedSequence<DriverSharingStrategy, [String]> in
                guard !isBranchLink && !isQR && !isTc else { return Driver.empty() }
                return Driver.of(["Kode QR yang anda scan invalid"])
            }
        
        let identifier = Driver.merge(isQR, isTc).filter { return $0 }
            .withLatestFrom(inputIdentifier)
            .flatMapLatest { inputIdentifier -> SharedSequence<DriverSharingStrategy, String> in
                if let range = inputIdentifier.range(of: "tokopedia://(tc|w)/", options: .regularExpression) {
                    let result = inputIdentifier.substring(from: range.upperBound)
                    return Driver.of(result)
                }
                return Driver.empty()
            }
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        // QR Payment
        // Check if user is authenticated
        let QRTag = isLogin.asDriverOnErrorJustComplete().filter { return $0 }
            .flatMapLatest { _ -> SharedSequence<DriverSharingStrategy, WalletStore> in
                return TokoCashUseCase.requestBalance()
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.map { response -> Bool in
                guard let data = response.data, data.abTags.contains("QR") else { return false }
                return true
            }
        // unauthenticated users message
        let userNotAuthorized = QRTag.filter { !$0 }
            .map { _ -> [String] in
                return ["Pengguna tidak terotorisasi"]
            }
        // get QR info
        let QRInfoResponse = QRTag.filter { return $0 }
            .withLatestFrom(identifier).flatMapLatest { identifier -> SharedSequence<DriverSharingStrategy, TokoCashQRInfoResponse> in
                return TokoCashUseCase.requestQRInfo(identifier)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .map { response -> TokoCashQRInfoResponse in
                        var rspn = response
                        rspn.data?.merchantIdentifier = identifier
                        return rspn
                    }
                    .asDriverOnErrorJustComplete()
            }
        
        // trigger campaign
        let trackCampaignResponse = isTc.filter { return $0 }
            .withLatestFrom(identifier)
            .flatMapLatest { identifier -> SharedSequence<DriverSharingStrategy, TriggerCampaignResponse> in
                TriggerCampaignTargetUseCase.requestQRTriggerCampaign(identifier: identifier)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
        
        let trackCampaignErrorMessage = trackCampaignResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, [String]> in
            guard let errorMessage = response.errorMessage else { return Driver.empty() }
            AnalyticsManager.trackEventName("campaignEvent", category: "trigger based campaign", action: "scan qr code - fail", label: errorMessage.joined(separator: "-"))
            return Driver.just(errorMessage)
        }
        
        // validation color
        let validationColor = Driver.merge(input.trigger.flatMapLatest {
            Driver.of(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        }, isBranchLink.map { isBranchLink -> UIColor in
            isBranchLink ? #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }, QRInfoResponse.map { response -> UIColor in
            guard let code = response.code, code == "200000" else { return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
            return #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        }, trackCampaignResponse.map { response -> UIColor in
            if response.errorMessage == nil {
                return #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
            }
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        })
        
        // navigation if success
        let QRInfo = QRInfoResponse.filter { response -> Bool in
            guard let code = response.code, code == "200000" else { return false }
            return true
        }.map { response -> TokoCashQRInfo? in
            return response.data
        }
        
        let triggerCampaign = trackCampaignResponse.flatMapLatest { response -> SharedSequence<DriverSharingStrategy, URL> in
            guard let stringURL = response.data, !stringURL.isEmpty, let url = URL(string: stringURL) else { return Driver.empty() }
            return Driver.of(url)
        }
        
        // error message
        let errorLocalization = errorTracker.flatMapLatest { error -> SharedSequence<DriverSharingStrategy, [String]> in
            guard let moyaError: MoyaError = error as? MoyaError, let response: Response = moyaError.response else { return Driver.empty() }
            let statusCode = response.statusCode
            if statusCode == 400 {
                return Driver.of(["Kode QR yang anda scan invalid"])
            } else if statusCode == 402 {
                return Driver.of(["Akun Anda belum terhubung dengan Tokocash"])
            } else {
                return Driver.of(["Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
            }
        }
        
        let failedMessage = Driver.merge(errorLocalization, userNotAuthorized, inValidQRCode, trackCampaignErrorMessage)
        
        return Output(needRequestAccess: needRequestAccess,
                      cameraSetting: cameraSetting,
                      setupCameraView: setupCameraView,
                      runCamera: runCamera,
                      accessCamera: accessCamera.asDriver(),
                      isHidePermission: isHidePermission,
                      isHideScanView: isHideScanView,
                      isHideFlashButton: isHideFlashButton,
                      flashButtonImage: flashButtonImage,
                      activityIndicator: activityIndicator.asDriver(),
                      validationColor: validationColor,
                      QRInfo: QRInfo,
                      triggerCampaign: triggerCampaign,
                      failedMessage: failedMessage)
    }
}
