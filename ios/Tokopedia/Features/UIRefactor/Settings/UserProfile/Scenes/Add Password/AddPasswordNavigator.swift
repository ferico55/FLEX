//
//  AddPasswordNavigator.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 4/2/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

public class AddPasswordNavigator {
    
    private let navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    public func backToProfileSettingsAfterSuccessAddPassword() {

        guard let viewControllers = navigationController?.viewControllers else { return }

        for vc in viewControllers {
            if let viewController = vc as? ProfileSettingViewController {
                viewController.userCreatedPassword = true
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
}
