//
//  UINavigationController+CompletionHandler.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 14/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UINavigationController {
    internal func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
