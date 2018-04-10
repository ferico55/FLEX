//
//  PaymentSettingNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc public class PaymentSettingNavigator: NSObject {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toSaveCC() {
        let vc = PaymentSaveCCViewController()
        let navigator = PaymentSaveCCNavigator(navigationController: navigationController)
        vc.viewModel = PaymentSaveCCViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toDetailCC(_ creditCard: CreditCardData) {
        let vc = PaymentDetailCCViewController()
        let navigator = PaymentDetailCCNavigator(navigationController: navigationController)
        vc.viewModel = PaymentDetailCCViewModel(creditCard: creditCard, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toAuthenticationSetting() {
        let vc = CCAuthenticationViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
