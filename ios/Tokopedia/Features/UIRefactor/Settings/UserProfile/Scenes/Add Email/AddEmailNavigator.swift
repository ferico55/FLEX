//
//  AddEmailNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 04/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class AddEmailNavigator {
    
    private let navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    public func goToEmailOTP(_ email: String) {
        let emailOTPViewController = EmailOTPViewController(email: email)
        navigationController?.pushViewController(emailOTPViewController, animated: true)
    }
}
