//
//  COTPService.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 29/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import SwiftyJSON
import UIKit

public enum CentralizedOTPType: String {
    case phoneNumberVerification = "11"
    case bankAccount = "12"
    case securityChallenge = "13"
    case changeEmail = "14"
    case checkout = "15"
    case rechargeCheckout = "16"
    case rechargeFirstTime = "17"
    case rechargeSubscribe = "171"
    case rechargeFauxBlacklist = "18"
    case rechargeBlacklist = "19"
    case phoneNumberChange = "20"
    case walletActivation = "111"
    case walletLogin = "112"
    case tokocashTransferP2P = "113"
    case registerPhoneNumber = "116"
    case paymentCreditCard = "121"
    case googleAuthenticatorActivation = "131"
}

private enum CentralizedOTPMode: String {
    case email
}

public class COTPService: NSObject {
    class public func getOTPModeList(type: CentralizedOTPType, userId: String, msisdn: String) -> Observable<ModeListResponse> {
        return AccountProvider().request(.centralizedOTPModeList(otpType: type, userId: userId, msisdn: msisdn))
            .mapJSON()
            .map { response -> ModeListResponse in
                let response = JSON(response)
                return ModeListResponse(json: response)
        }
    }

    class public func requestCentralizedOTP(type: CentralizedOTPType, modeDetail: ModeListDetail, phoneNumber: String, userId: String) -> Observable<COTPResponse> {
        return AccountProvider().request(.requestCentralizedOtp(otpType: type, modeDetail: modeDetail, phoneNumber: phoneNumber, userId: userId))
            .mapJSON()
            .map { response -> COTPResponse in
                let response = JSON(response)
                return COTPResponse(json: response)
        }
    }

    class public func requestCentralizedOTPToEmail(type: CentralizedOTPType, userId: String, userEmail: String) -> Observable<COTPResponse> {
        return AccountProvider().request(.requestCentralizedOtpToEmail(userId: userId, userEmail: userEmail, otpType: type))
            .mapJSON()
            .map { response -> COTPResponse in
                let response = JSON(response)
                return COTPResponse(json: response)
        }
    }

    class public func validateCentralizedOTP(type: CentralizedOTPType, userId: String, code: String, msisdn: String = "") -> Observable<COTPResponse> {
        return AccountProvider().request(.validateCentralizedOtp(userId: userId, code: code, otpType: type, msisdn: msisdn))
            .mapJSON()
            .map { response -> COTPResponse in
                let response = JSON(response)
                return COTPResponse(json: response)

        }
    }

    class public func resendOTP(type: CentralizedOTPType, modeDetail: ModeListDetail, accountInfo: AccountInfo?) -> Observable<COTPResponse> {
        let userManager = UserAuthentificationManager()
        var userId = accountInfo?.userId ?? ""
        var userEmail = accountInfo?.email ?? ""
        var phoneNumber = accountInfo?.phoneNumber ?? ""

        if userManager.isLogin {
            userId = userManager.getUserId()
            userEmail = userManager.getUserEmail()
            phoneNumber = userManager.getUserPhoneNumber() ?? "0"
        }

        if modeDetail.modeText == CentralizedOTPMode.email.rawValue {
            return self.requestCentralizedOTPToEmail(type: type, userId: userId, userEmail: userEmail)
        } else {
            return self.requestCentralizedOTP(type: type, modeDetail: modeDetail, phoneNumber: phoneNumber, userId: userId)
        }
    }
}
