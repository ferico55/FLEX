//
//  TokoCashHelpNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 05/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashHelpNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toPreviousPage() {
        navigationController.popViewController(animated: true)
    }
}
