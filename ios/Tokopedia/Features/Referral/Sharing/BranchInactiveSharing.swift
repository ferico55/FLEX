//
//  BranchInactiveSharing.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 18/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
class BranchInactiveSharing: NSObject {
    func share(object:Referable?, from viewController: UIViewController, anchor: UIView!) {
        
        if let refObject = object, let url = URL(string: refObject.desktopUrl) {
            if let controller = UIActivityViewController.shareDialog(withTitle: refObject.title, url: url, anchor: anchor) {
                viewController.present(controller, animated: true, completion: nil)
            }
        }
    }
}
