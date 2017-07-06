//
//  TKPDBannerTimer.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 6/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc(TKPDBannerTimer)
class TKPDBannerTimer: NSObject {
    
    static func getTimer(slider: iCarousel) -> Timer {
        
        let timer = Timer.bk_timer(withTimeInterval: 5.0, block: { (timer) in
            slider.scrollToItem(at: slider.currentItemIndex + 1, duration: 1.0)
        }, repeats: true)!
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        return timer
    }
}
