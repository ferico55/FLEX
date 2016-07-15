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
    private var lastFireTime:dispatch_time_t = 0
    
    //when this function is not called for specific time, do the action
    //if this function is called again, reset the delay time with the new one
    func whenNotCalledFor(delay:NSTimeInterval, doAction:(()->()) )
    {
        let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
        
        self.lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            dispatch_get_main_queue()) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(self.lastFireTime, dispatchDelay)
                if now >= when {
                    doAction()
                }
        }
    }
}