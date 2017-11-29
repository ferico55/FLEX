//
//  ViewControllerSwipeGestureProtocol.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 14/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol ViewControllerSwipeGestureProtocol {
    
}

extension ViewControllerSwipeGestureProtocol where Self: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}
