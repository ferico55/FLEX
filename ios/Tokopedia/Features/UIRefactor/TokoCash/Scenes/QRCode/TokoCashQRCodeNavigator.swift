//
//  TokoCashQRCodeNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc final public class TokoCashQRCodeNavigator: NSObject {
    
    private let navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    public func toQRPayment(_ QRInfo: TokoCashQRInfo) {
        guard let nv = navigationController else { return }
        let vc = TokoCashQRPaymentViewController()
        let navigator = TokoCashQRPaymentNavigator(navigationController: nv)
        vc.viewModel = TokoCashQRPaymentViewModel(QRInfo: QRInfo, navigator: navigator)
        navigationController?.pushViewController(vc, animated: true)
    }

    public func toAppSetting() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    debugPrint("Settings opened: \(success)") // Prints true
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
}
