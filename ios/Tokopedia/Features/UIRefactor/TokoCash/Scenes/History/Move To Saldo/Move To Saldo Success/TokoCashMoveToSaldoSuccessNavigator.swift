//
//  TokoCashMoveToSaldoStatusNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashMoveToSaldoSuccessNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func backToTokoCash() {
        for vc in navigationController.viewControllers {
            if let viewController = vc as? TokoCashViewController {
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }
}
