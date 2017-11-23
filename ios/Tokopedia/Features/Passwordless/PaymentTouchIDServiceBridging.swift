//
//  PaymentTouchIDServiceBridging.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 15/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import SwiftOverlays
import KeychainAccess

class PaymentTouchIDServiceBridging: NSObject {

    private let service = PaymentTouchIDService()
    private let cryptoManager = TPCryptoManager()

    func registerPublicKey(transactionID: String, ccHash: String, onSuccess: @escaping ((String) -> Void), onError: @escaping ((String?) -> Void)) {

        guard let topView = UIApplication.topViewController()?.view else { return }
        SwiftOverlays.showCenteredWaitOverlay(topView)

        service.saveTouchID(transactionID: transactionID, ccHash: ccHash)
            .subscribe(onNext: { result in
                DispatchQueue.main.async {
                    SwiftOverlays.removeAllOverlaysFromView(topView)
                }
                if result.success {
                    onSuccess("Registrasi sidik jari berhasil")
                } else {
                    onError("Touch ID gagal")
                }

            }, onError: { error in

                DispatchQueue.main.async {
                    SwiftOverlays.removeAllOverlaysFromView(topView)
                }

                var errorMessage: String? = "Touch ID gagal"
                if let error = error as? PaymentTouchIDError {
                    switch error {
                    case .touchIDLockout:
                        errorMessage = "Fitur Touch ID terblokir. Silakan aktifkan Touch ID kembali untuk melanjutkan proses registrasi"
                    default: break
                    }
                }

                onError(errorMessage)

            }).disposed(by: rx_disposeBag)
    }

    func validateTouchIDPayment(parameter: [String: Any], onSuccess: @escaping ((String, String) -> Void), onError: @escaping ((String?) -> Void)) {

        guard let topView = UIApplication.topViewController()?.view else { return }
        SwiftOverlays.showCenteredWaitOverlay(topView)

        service.validatePayment(parameter: parameter)
            .subscribe(onNext: { result in
                DispatchQueue.main.async {
                    SwiftOverlays.removeAllOverlaysFromView(topView)
                }

                onSuccess(result.urlString ?? "", result.parameterString ?? "")

            }, onError: { error in

                DispatchQueue.main.async {
                    SwiftOverlays.removeAllOverlaysFromView(topView)
                }

                var errorMessage: String? = "Touch ID gagal, lanjutkan menggunakan SMS OTP"
                if let error = error as? PaymentTouchIDError {
                    switch error {
                    case .touchIDLockout:
                        errorMessage = "Fitur Touch ID terblokir, lanjutkan menggunakan SMS OTP"
                    case .publicKeyNotExist:
                        errorMessage = nil
                    default: break
                    }
                }

                onError(errorMessage)

            }).disposed(by: rx_disposeBag)
    }

    func doResetAllPaymentTouchID() {
        cryptoManager.deletePublicKey().subscribe(onNext: { () in
            let keychain = Keychain(service: KeychainAccessService.creditCard)
            do {
                try keychain.removeAll()
                DispatchQueue.main.async {
                    StickyAlertView.showSuccessMessage(["Success Reset All Payment TouchID settings"])
                }
            } catch {
                StickyAlertView.showErrorMessage(["Failed Reset All Payment TouchID settings"])
            }
        }).disposed(by: rx_disposeBag)
    }

    func getPublicKey() -> String {
        if let publicKey = self.cryptoManager.getPublicKey(),
            self.service.isFirstRegisteredPublicKey(publicKey) == false {
            return publicKey
        } else {
            return ""
        }
    }
}
