//
//  TokoCashDateFilterNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashDateFilterNavigator {
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func backToPreviousController() {
        navigationController.popViewController(animated: true)
    }
}
