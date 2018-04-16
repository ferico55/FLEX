//
//  EmailOTPNavigator.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/27/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class EmailOTPNavigator {
    
    private let navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    public func backToProfileSettings() {
        guard let viewControllers = navigationController?.viewControllers else { return }
        for vc in viewControllers {
            if let viewController = vc as? SettingUserProfileViewController {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
}
