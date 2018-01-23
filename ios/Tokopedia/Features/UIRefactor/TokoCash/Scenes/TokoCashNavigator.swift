//
//  TokoCashNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 26/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class TokoCashNavigator {
    let storyboard: UIStoryboard
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toNominal(_ delegate: TokoCashNominalDelegate, nominal: [DigitalProduct]) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashNominalViewController.self)
        let nc = UINavigationController(rootViewController: vc)
        let viewModel = TokoCashNominalViewModel(items: nominal)
        vc.delegate = delegate
        vc.viewModel = viewModel
        navigationController.present(nc, animated: true)
    }
    
    func toWalletHistory() {
        let vc = storyboard.instantiateViewController(ofType: TokoCashHistoryListViewController.self)
        let navigator = TokoCashHistoryListNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHistoryListViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toAccountSetting() {
        let vc = storyboard.instantiateViewController(ofType: TokoCashProfileViewController.self)
        let navigator = TokoCashProfileNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashProfileViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toHelpWebView() {
        let URL = "https://www.tokopedia.com/bantuan/pembeli/fitur-belanja/tokocash/"
        let controller = WKWebViewController(urlString: URL)
        controller.title = "Bantuan"
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: false)
    }
    
    func toDigitalCart(_ categoryID: String) {
        let vc = DigitalCartViewController(cart: Observable.of(categoryID))
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
}
