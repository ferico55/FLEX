//
//  ReactSplitViewController.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 10/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import UIKit

internal class ReactSplitViewController: UIViewController {

    internal let splitVC: UISplitViewController
    private let showNavigationBar: Bool
    
    convenience internal init(masterModule: ReactModule, detailModule: ReactModule) {
        self.init(masterModule: masterModule, detailModule: detailModule, showNavigationBar: false)
    }
    
    internal init(masterModule: ReactModule, detailModule: ReactModule, showNavigationBar: Bool) {
        self.splitVC = UISplitViewController()
        self.showNavigationBar = showNavigationBar
        super.init(nibName: nil, bundle: nil)

        var leftViewController: ReactViewController
        if let props = masterModule.props {
            leftViewController = ReactViewController(moduleName: masterModule.name, props: props)
        } else {
            leftViewController = ReactViewController(moduleName: masterModule.name)
        }
        let masterViewController = UINavigationController(rootViewController: leftViewController)
        masterViewController.navigationBar.isTranslucent = false

        var rightViewController: ReactViewController
        if let props = detailModule.props {
            rightViewController = ReactViewController(moduleName: detailModule.name, props: props)
        } else {
            rightViewController = ReactViewController(moduleName: detailModule.name)
        }
        let detailViewController = UINavigationController(rootViewController: rightViewController)
        detailViewController.navigationBar.isTranslucent = false
        
        self.splitVC.viewControllers = [masterViewController, detailViewController]
        self.splitVC.delegate = self
        self.view.addSubview(splitVC.view)
        self.addChildViewController(self.splitVC)
        self.splitVC.didMove(toParentViewController: self)
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!self.showNavigationBar){
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    deinit {
        // need to be in deinit instead of viewWillDissappear to prevent bug on presenting popover here
        if(!self.showNavigationBar){
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReactSplitViewController: UISplitViewControllerDelegate {
    public func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}

extension ReactSplitViewController: CustomTopMostViewController {
    public func customTopMostViewController() -> UIViewController? {
        return splitVC.viewControllers[1]
    }
}
