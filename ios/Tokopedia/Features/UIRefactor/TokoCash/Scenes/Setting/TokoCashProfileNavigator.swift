//
//  TokoCashProfileNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 05/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashProfileNavigator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toHome() {
        navigationController.popToRootViewController(animated: true)
    }
    
}
