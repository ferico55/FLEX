//
//  RequestErrorHandler.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxSwift

internal class RequestErrorHandler: NSObject {

    internal class func redirectToMaintenance() {
        NavigateViewController.navigateToMaintenanceViewController()
    }

    internal class func handleForceLogout(responseType: String, urlString: String, onSuccess: @escaping () -> Void) {
        AuthenticationService.shared.getNewToken { _, error in
            if error == nil {
                switch responseType {
                case "INVALID_REQUEST":
                    onSuccess()
                case "REQUEST_DENIED":
                    _ = AuthenticationService
                        .shared
                        .reloginAccount()
                        .subscribe(onNext: {
                            onSuccess()
                        })
                default:
                    break
                }
            } else {
                LogEntriesHelper.logForceLogout(lastURL: urlString)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
            }
        }

    }
}
