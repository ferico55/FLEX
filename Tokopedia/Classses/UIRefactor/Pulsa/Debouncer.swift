//
//  Debouncer.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class Debouncer: NSObject {
    var callback: (() -> ())
    var delay: Double
    weak var timer: NSTimer?
    
    init(delay: Double, callback: (() -> ())) {
        self.delay = delay
        self.callback = callback
    }
    
    func call() {
        timer?.invalidate()
        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: "fireNow", userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    func fireNow() {
        self.callback()
    }
}