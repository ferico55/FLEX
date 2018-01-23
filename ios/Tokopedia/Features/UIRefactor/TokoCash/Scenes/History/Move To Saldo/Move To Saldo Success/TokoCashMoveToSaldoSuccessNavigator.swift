//
//  TokoCashMoveToSaldoStatusNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashMoveToSaldoSuccessNavigator {

    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func backToTokoCash() {
        for vc in navigationController.viewControllers {
            if let viewController = vc as? TokoCashViewController {
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }
}
