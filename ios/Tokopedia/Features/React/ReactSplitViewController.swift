//
//  ReactSplitViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 10/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation

class ReactSplitViewController: UIViewController {

    let modules: [String: Any]
    let splitVC: UISplitViewController

    init(modules: [String: Any], masterViewKey: String, detailViewKey: String) {
        self.modules = modules
        self.splitVC = UISplitViewController()
        super.init(nibName: nil, bundle: nil)

        guard let firstProps = modules[masterViewKey] as? [String: AnyObject], let secondProps = modules[detailViewKey] as? [String:AnyObject] else {
            return
        }

        let leftViewController = ReactViewController(moduleName: masterViewKey, props: firstProps)
        let masterViewController = UINavigationController(rootViewController: leftViewController)
        masterViewController.navigationBar.isTranslucent = false

        let rightViewController = ReactViewController(moduleName: detailViewKey, props: secondProps)
        let detailViewController = UINavigationController(rootViewController: rightViewController)
        detailViewController.navigationBar.isTranslucent = false

        self.splitVC.viewControllers = [masterViewController, detailViewController]
        self.splitVC.delegate = self
        self.view.addSubview(splitVC.view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReactSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}
