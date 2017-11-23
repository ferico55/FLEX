//
//  PaymentTouchIDService.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 04/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import Moya
import MoyaUnbox
import KeychainAccess
import LocalAuthentication

enum PaymentTouchIDError: Swift.Error {
    case saveToAccountFailed
    case publicKeyNotExist
    case touchIDLockout
    case userCancel
    case unknown
}

class PaymentTouchIDService: NSObject {

    private var scroogeProvider = ScroogeProvider()
    private var accountProvider = AccountProvider()
    private var cryptoManager = TPCryptoManager()

    func saveTouchID(transactionID: String, ccHash: String) -> Observable<PaymentActionResponse> {

        let hasPublicKey = cryptoManager.hasPublicKey()
        let getPublicKey = cryptoManager.getOrCreatePublicKey().shareReplay(1)
        let currentDate = getCurrentDateString()
        let signature = getPublicKey.flatMap { _ in
            self.getSignature(dateString: currentDate).shareReplay(1)
        }

        return
            authorizeTouchID(reason: "Touch ID menggantikan SMS OTP. Scan sidik jari Anda untuk kemudahan transaksi", cancelButtonTitle: "Tutup").flatMap({ _ in
                Observable.zip(getPublicKey, signature)
            }).flatMap({ publicKey, signature -> Observable<PaymentActionResponse> in
                self.savePublicKeyToServer(publicKey: publicKey,
                                           signature: signature,
                                           transactionID: transactionID,
                                           ccHash: ccHash,
                                           isNewPublicKey: !hasPublicKey,
                                           dateString: currentDate)
            }).flatMap({ response in
                getPublicKey.map({ publicKey -> PaymentActionResponse in
                    if response.success {
                        self.savePublicKeyToKeychain(publicKey: publicKey, ccHash: ccHash)
                    }
                    return response
                })
            })
    }

    private func authorizeTouchID(reason: String, cancelButtonTitle: String) -> Observable<()> {
        return cryptoManager.authorizeTouchID(reason: reason, cancelButtonTitle: cancelButtonTitle)
            .catchError({ error in

                guard let error = error as? LAError else {
                    return .error(PaymentTouchIDError.unknown)
                }

                switch error {
                case LAError.userCancel :
                    return .error(PaymentTouchIDError.userCancel)
                case LAError.touchIDLockout:
                    return .error(PaymentTouchIDError.touchIDLockout)
                default:
                    return .error(PaymentTouchIDError.unknown)
                }
            })
    }

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, dd MMM yyyy HH:mm:ss Z"
        let usLocale = Locale(identifier: "en_US")
        formatter.locale = usLocale as Locale
        let dateString = formatter.string(from: Date())

        return dateString
    }

    func validatePayment(parameter: [String: Any]) -> Observable<PaymentActionResponse> {

        guard let ccHash = parameter["cc_hashed"] as? String,
            let publicKey = self.cryptoManager.getPublicKey(),
            self.isRegisteredPublicKey(publicKey: publicKey, ccHash: ccHash)
        else {
            return .error(PaymentTouchIDError.publicKeyNotExist)
        }

        let currentDate = getCurrentDateString()

        return
            authorizeTouchID(reason: "Scan sidik jari untuk menyelesaikan transaksi", cancelButtonTitle: "Gunakan OTP").flatMap({ () -> Observable<String> in
                self.getSignature(dateString: currentDate)
            }).flatMap({ signature -> Observable<PaymentActionResponse> in
                self.validatePaymentToScrooge(publicKey: publicKey,
                                              signature: signature,
                                              parameter: parameter,
                                              dateString: currentDate)
            })
    }

    private func savePublicKeyToServer(publicKey: String,
                                       signature: String,
                                       transactionID: String,
                                       ccHash: String,
                                       isNewPublicKey: Bool,
                                       dateString: String) -> Observable<PaymentActionResponse> {

        let accountPublicKey: Observable<PublicKeyResult>

        if isNewPublicKey {
            accountPublicKey = savePublicKeyToAccount(publicKey: publicKey)
        } else {
            accountPublicKey = .just(PublicKeyResult(isSuccess: true))
        }

        return
            accountPublicKey
            .flatMap({ result -> Observable<PaymentActionResponse> in
                if result.isSuccess {
                    return self.savePublicKeyToScrooge(publicKey: publicKey,
                                                       signature: signature,
                                                       transactionID: transactionID,
                                                       ccHash: ccHash,
                                                       dateString: dateString)
                } else {
                    return .error(PaymentTouchIDError.saveToAccountFailed)
                }
            })
    }

    private func savePublicKeyToAccount(publicKey: String) -> Observable<PublicKeyResult> {
        return accountProvider
            .request(.registerPublicKey(withKey: publicKey))
            .map(to: PublicKeyResult.self)
    }

    private func savePublicKeyToScrooge(publicKey: String,
                                        signature: String,
                                        transactionID: String,
                                        ccHash: String,
                                        dateString: String) -> Observable<PaymentActionResponse> {
        return scroogeProvider
            .request(.register(PublicKey: publicKey,
                               signature: signature,
                               transactionID: transactionID,
                               ccHash: ccHash,
                               dateString: dateString))
            .map(to: PaymentActionResponse.self)
    }

    func validatePaymentToScrooge(publicKey: String,
                                  signature: String,
                                  parameter: [String: Any],
                                  dateString: String) -> Observable<PaymentActionResponse> {
        return scroogeProvider.request(.validatePayment(PublicKey: publicKey,
                                                        signature: signature,
                                                        parameter: parameter,
                                                        dateString: dateString))
            .map(to: PaymentActionResponse.self)
    }

    private func isRegisteredPublicKey(publicKey: String, ccHash: String) -> Bool {
        let keychain = Keychain(service: KeychainAccessService.creditCard)
        if let creditCardDatas = keychain[data: KeychainAccessKey.creditCard],
            let creditCards = NSKeyedUnarchiver.unarchiveObject(with: creditCardDatas) as? [CreditCardTouchIDData] {
            let auth = UserAuthentificationManager()
            return creditCards.contains(where: { (creditCard) -> Bool in
                (
                    creditCard.publicKey == publicKey &&
                        creditCard.ccHash == ccHash &&
                        creditCard.userID == auth.getUserId()
                )
            })
        } else {
            return false
        }
    }

    func isFirstRegisteredPublicKey(_ publicKey: String) -> Bool {
        let keychain = Keychain(service: KeychainAccessService.creditCard)
        if let creditCardDatas = keychain[data: KeychainAccessKey.creditCard],
            let creditCards = NSKeyedUnarchiver.unarchiveObject(with: creditCardDatas) as? [CreditCardTouchIDData] {
            return creditCards.contains(where: { (creditCard) -> Bool in
                creditCard.publicKey != publicKey
            })
        } else {
            return false
        }
    }

    private func savePublicKeyToKeychain(publicKey: String, ccHash: String) {
        let keychain = Keychain(service: KeychainAccessService.creditCard)
        let auth = UserAuthentificationManager()
        let newCreditCardData = CreditCardTouchIDData(userID: auth.getUserId(),
                                                      ccHash: ccHash,
                                                      publicKey: publicKey)
        let creditCards: [CreditCardTouchIDData]?

        if let creditCardDatas = keychain[data: KeychainAccessKey.creditCard],
            let currentCreditCards = NSKeyedUnarchiver.unarchiveObject(with: creditCardDatas) as? [CreditCardTouchIDData] {
            creditCards = currentCreditCards + [newCreditCardData]
        } else {
            creditCards = [newCreditCardData]
        }
        if let creditCards = creditCards {
            let data = NSKeyedArchiver.archivedData(withRootObject: creditCards)
            keychain[data: KeychainAccessKey.creditCard] = data
        }
    }

    private func getSignature(dateString: String) -> Observable<String> {

        let auth = UserAuthentificationManager()
        let userID = auth.getUserId() ?? ""

        return cryptoManager.signMessage("\(userID)\(dateString)")
    }
}
