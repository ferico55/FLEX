//
//  TokoCashFailedNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashQRPaymentFailedNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toQRPage() {
        for vc in navigationController.viewControllers {
            if let viewController = vc as? TokoCashQRCodeViewController {
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }
}
