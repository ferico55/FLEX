//
//  WebviewPopover.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 7/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Popover

@IBDesignable
class WebviewPopover: Popover {
    
    @IBOutlet var popView: UIView?
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        let options = [
            .type(.down),
            .animationIn(0.3),
            .blackOverlayColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)),
            .dismissOnBlackOverlayTap(true)
            ] as [PopoverOption]
        super.init(options: options)
        
        self.viewController = viewController
        
        popView = Bundle.main.loadNibNamed("PivotNavigationView", owner: self, options: nil)?[0] as! UIView
        
        var frame = self.popView?.frame
        frame?.size.width = UIScreen.main.bounds.size.width
        frame?.size.height = 101
        self.popView?.frame = frame!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapShow(coordinate: CGPoint) {
        self.show(popView!, point: coordinate)
    }
    
    // MARK: - Navigation
    @IBAction func tapHome(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(kTKPD_REDIRECT_TO_HOME), object: nil)
        self.dismiss()
        viewController?.navigationController?.popToRootViewController(animated: true)
        AnalyticsManager.trackEventName("clickNavigationMenu", category: "Navigation", action: GA_EVENT_ACTION_CLICK, label: "Go To Home Page")
    }

    @IBAction func tapHelp(_ sender: Any) {
        NavigateViewController.navigateToContactUs(from: viewController)
        self.dismiss()
        AnalyticsManager.trackEventName("clickNavigationMenu", category: "Navigation", action: GA_EVENT_ACTION_CLICK, label: "Go To Help Page")
    }
}

extension UIBarButtonItem {
    
    class func make(controller: UIViewController, selector: Selector) -> UIBarButtonItem {
        let navMenu = UIImage(named: "icon_menu_group_9")!.withRenderingMode(.alwaysOriginal)
        return UIBarButtonItem.init(image: navMenu, style: .plain, target: controller, action: selector)
    }
}
