//
//  TokoCashQRCodeViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

@objc class TokoCashQRCodeViewModel: NSObject, ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let hasTorch: Driver<Bool>
        let isTorchAvailable: Driver<Bool>
        let isTorchActive: Driver<Bool>
        let identifier: Driver<String>
    }
    
    struct Output {
        let showFlashButton: Driver<Bool>
        let flashButtonImage: Driver<UIImage?>
        let validationColor: Driver<UIColor>
        let QRInfo: Driver<TokoCashQRInfo?>
        let failedMessage: Driver<String>
    }
    
    private let navigator: TokoCashQRCodeNavigator
    
    init(navigator: TokoCashQRCodeNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let showFlashButton = Driver.combineLatest(input.hasTorch, input.isTorchAvailable) { hasTorch, isTorchAvailable in
            return !(hasTorch && isTorchAvailable)
        }
        
        let flashButtonImage = input.isTorchActive.map { isActive -> UIImage? in
            guard isActive else { return UIImage(named: "icon_flash_off") }
            return UIImage(named: "icon_flash_on")
        }
        
        let requestActivity = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let QRInfoResponse = input.identifier
            .distinctUntilChanged()
            .filter { identifier -> Bool in
                !identifier.isEmpty
            }
            .flatMapLatest { identifier -> SharedSequence<DriverSharingStrategy, TokoCashQRInfoResponse> in
                return TokoCashUseCase.requestQRInfo(identifier)
                    .trackActivity(requestActivity)
                    .trackError(errorTracker)
                    .map { response -> TokoCashQRInfoResponse in
                        var rspn = response
                        rspn.data?.merchantIdentifier = identifier
                        return rspn
                    }
                    .asDriverOnErrorJustComplete()
        }
        
        let validationColor = Driver.merge(input.trigger.flatMapLatest { return Driver.of(UIColor.white) }, QRInfoResponse.map { response -> UIColor in
            guard let code = response.code, code == "200000" else { return UIColor.white }
            return UIColor.tpGreen()
        })
        
        let QRInfo = QRInfoResponse.filter { response -> Bool in
            guard let code = response.code, code == "200000" else { return false }
            return true
            }.map{ response -> TokoCashQRInfo? in
                return response.data
            }.delay(0.3).do(onNext: { data in
                guard let QRInfo = data else { return }
                self.navigator.toQRPayment(QRInfo)
            })
        
        let failedMessage = errorTracker.flatMapLatest { error -> SharedSequence<DriverSharingStrategy, String> in
            guard let moyaError: MoyaError = error as? MoyaError, let response: Response = moyaError.response else { return Driver.empty() }
            switch response.statusCode {
            case 400 :return Driver.of("Kode QR yang anda scan invalid")
            default: return Driver.of("Terjadi kendala pada server. Mohon coba beberapa saat lagi.")
            }
        }
        
        return Output(showFlashButton: showFlashButton,
                      flashButtonImage: flashButtonImage,
                      validationColor: validationColor,
                      QRInfo: QRInfo,
                      failedMessage: failedMessage)
    }
}
