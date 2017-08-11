//
//  ReplacementSplitViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReplacementSplitViewController: UIViewController, UISplitViewControllerDelegate {
    
    let splitVC: UISplitViewController = UISplitViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitVC.delegate = self
        let master = UINavigationController()
        let detail = UINavigationController()
        let masterViewController = ReplacementListViewController()
        masterViewController.splitView = self
        master.viewControllers = [masterViewController]
        let detailViewController = UIViewController()
        detailViewController.view.backgroundColor = .tpBackground()
        detail.viewControllers = [detailViewController]
        self.splitVC.viewControllers = [master, detail]
        self.splitVC.preferredDisplayMode = .allVisible
        
        self.view.addSubview(splitVC.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
//    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//        
//        if let nc = secondaryViewController as? UINavigationController {
//            if let topVc = nc.topViewController {
//                if let dc = topVc as? ReplacementDetailViewController {
//                    let hasDetail = Thing.noThing !== dc.thing
//                    return !hasDetail
//                }
//            }
//        }
//        return true
//    }

}
