//
//  TokoCashMoveToSaldoFailedNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashMoveToSaldoFailedNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func backToMoveToSaldo() {
        navigationController.popViewController(animated: true)
    }
    
    public func backToTokoCash() {
        for vc in navigationController.viewControllers {
            if let viewController = vc as? TokoCashViewController {
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }
}
