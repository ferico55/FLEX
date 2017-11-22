//
//  ReactSplitViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 10/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation

class ReactSplitViewController: UIViewController, UISplitViewControllerDelegate {
    
    let modules: [String: Any]
    let splitVC: UISplitViewController
    
    init(modules: [String: Any]) {
        self.modules = modules
        self.splitVC = UISplitViewController()
        super.init(nibName: nil, bundle: nil)
        
        let firstKey = Array(modules.keys)[0]
        let secondKey = Array(modules.keys)[1]
        
        var leftViewController:ReactViewController
        var rightViewController:ReactViewController
        
        if let firstProps = modules[firstKey] as? [String: AnyObject] {
            leftViewController = ReactViewController(moduleName: firstKey, props: firstProps)
        } else {
            leftViewController = ReactViewController(moduleName: firstKey)
        }
        
        if let secondProps = modules[secondKey] as? [String:AnyObject]  {
            rightViewController = ReactViewController(moduleName: secondKey, props: secondProps)
        } else {
            rightViewController = ReactViewController(moduleName: secondKey)
        }
        
        let masterViewController = UINavigationController(rootViewController: leftViewController)
        masterViewController.navigationBar.isTranslucent = false
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
    
    deinit {
        // need to be in deinit instead of viewWillDissappear to prevent bug on presenting popover here
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
