//
//  TokoCashNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 26/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import UIKit

public class TokoCashNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toNominal(nominal: [DigitalProduct]) -> TokoCashNominalViewController {
        let vc = TokoCashNominalViewController()
        let nc = UINavigationController(rootViewController: vc)
        let viewModel = TokoCashNominalViewModel(items: nominal)
        vc.viewModel = viewModel
        navigationController.present(nc, animated: true)
        return vc
    }
    
    public func toWalletHistory() {
        let vc = TokoCashHistoryListViewController()
        let navigator = TokoCashHistoryListNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHistoryListViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toAccountSetting() {
        let vc = TokoCashProfileViewController()
        let navigator = TokoCashProfileNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashProfileViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toHelpWebView() {
        let URL = "https://www.tokopedia.com/bantuan/pembeli/fitur-belanja/tokocash/"
        let controller = WKWebViewController(urlString: URL)
        controller.title = "Bantuan"
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: false)
    }
    
    public func toDigitalCart(_ categoryID: String) {
        let vc = DigitalCartViewController(cart: Observable.of(categoryID))
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
}
