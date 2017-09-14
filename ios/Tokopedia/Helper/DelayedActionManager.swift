//
//  DelayedActionManager.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class DelayedActionManager : NSObject
{
    fileprivate var lastFireTime:DispatchTime!
    
    //when this function is not called for specific time, do the action
    //if this function is called again, reset the delay time with the new one
    func whenNotCalledFor(_ delay:TimeInterval, doAction:@escaping (()->Void) )
    {
        let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
        
        self.lastFireTime = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(dispatchDelay) / Double(NSEC_PER_SEC)) {
                let now = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
                let when = self.lastFireTime + Double(dispatchDelay) / Double(NSEC_PER_SEC)
                if now >= when {
                    doAction()
                }
        }
    }
}
