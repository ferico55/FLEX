//
//  TokoCashQRPaymentSuccessNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashQRPaymentSuccessNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func backToHome() {
        navigationController.popToRootViewController(animated: true)
    }
    
    public func toHelp(_ transactionId: String) {
        let vc = TokoCashHelpViewController()
        let navigator = TokoCashHelpNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHelpViewModel(transactionId, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
