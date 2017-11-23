//
//  TPCryptoManager.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 04/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import KeychainAccess
import LocalAuthentication

enum cryptoError: Swift.Error {
    case unknownError
    case cryptoError // throw any exception when encrypt
    case nullKeyError // keys not exists
    case saveKeyError // Request to server error when saving
    case unauthorizedError // touch id was not authorized
}

class TPCryptoManager: NSObject {

    func deletePublicKey() -> Observable<Void> {
        if hasPublicKey() {
            return .create({ (observer) -> Disposable in
                AsymmetricCryptoManager.sharedInstance.deleteSecureKeyPair { isSuccess in
                    if isSuccess {
                        observer.onNext()
                    } else {
                        observer.onError(cryptoError.cryptoError)
                    }
                }
                return Disposables.create()
            })
        } else {
            return Observable<Void>.just()
        }
    }

    func createPublicKey() -> Observable<Void> {
        return
            .create({ (observer) -> Disposable in
                AsymmetricCryptoManager.sharedInstance.createSecureKeyPair({ (success, _) -> Void in
                    if success {
                        observer.onNext()
                    } else {
                        observer.onError(cryptoError.cryptoError)
                    }

                })
                return Disposables.create()
            })
    }

    func getPublicKey() -> String? {
        guard let publicKeyData = AsymmetricCryptoManager.sharedInstance.getPublicKeyData() else {
            return nil
        }
        let exportImportManager = CryptoExportImportManager()
        let pubString = exportImportManager.exportRSAPublicKeyToPEM(publicKeyData, keyType: "com.AsymmetricCrypto.keypair" + (kSecAttrKeyTypeRSA as String), keySize: 2048)
        let data = Data(pubString.utf8)
        return data.base64EncodedString()
    }

    func getOrCreatePublicKey() -> Observable<String> {
        if hasPublicKey() {
            return Observable.just(getPublicKey() ?? "")
        } else {
            return
                createPublicKey().map({ _ in
                    self.getPublicKey() ?? ""
                })
        }
    }

    func signMessage(_ message: String) -> Observable<String> {
        return .create({ (observer) -> Disposable in
            DispatchQueue.global().async {
                AsymmetricCryptoManager.sharedInstance.signMessageWithPrivateKey(message, completion: { _, data, error in
                    guard error == nil else {
                        observer.onError(cryptoError.nullKeyError)
                        return
                    }
                    let b64encoded = data?.base64EncodedString()
                    observer.onNext(b64encoded ?? "")
                })
            }

            return Disposables.create()
        })
    }

    func authorizeTouchID(reason: String, cancelButtonTitle: String? = "") -> Observable<Void> {
        return .create({ (observer) -> Disposable in
            let context = LAContext()
            context.localizedFallbackTitle = ""
            if #available(iOS 10.0, *) {
                context.localizedCancelTitle = cancelButtonTitle
            }
            let reason = reason
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { success, error in
                if success {
                    observer.onNext()
                } else {

                    if let error = error as? LAError {
                        observer.onError(error)
                    } else {
                        observer.onError(cryptoError.unauthorizedError)
                    }
                }
            })

            return Disposables.create()
        })
    }

    func hasPublicKey() -> Bool {
        return AsymmetricCryptoManager.sharedInstance.keyPairExists()
    }
}
