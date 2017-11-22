//
//  UIViewController+ReactNavigation.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 9/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NativeNavigation

extension UIViewController {

    @objc(presentReactViewController:animated:completion:)
    public func objc_presentReactViewController(
        _ viewControllerToPresent: ReactViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        self.presentReactViewController(viewControllerToPresent, animated: animated, completion: completion)
    }
}
