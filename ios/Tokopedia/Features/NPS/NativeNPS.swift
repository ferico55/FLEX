//
//  NativeNPS.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(NativeNPS)
class NativeNPS: NSObject {
    class func show() {
        guard let lastRatingNPSVersion = UserDefaults.standard.lastVersionNPSRated,
            let currentVersion = Bundle.main.releaseVersionNumber else {
                let ratingView = NativeNPSView()
                ratingView.showNPS()
                return
        }
        
        if NativeNPS.shouldWriteReview(last: Version(lastRatingNPSVersion), current: Version(currentVersion)) {
            let ratingView = NativeNPSView()
            ratingView.showNPS()
        }
    }
    
    private class func shouldWriteReview(last: Version, current: Version) -> Bool {
        if last.major < current.major || last.minor < current.minor || last.patch < current.patch {
            return true
        } else {
            return false
        }
    }
}

fileprivate struct Version {
    public private(set) var major: Int = 0
    public private(set) var minor: Int = 0
    public private(set) var patch: Int = 0
    
    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public init(_ string: String) {
        let components = string.characters.split(separator: ".").map { String($0) }
        
        if components.count > 0, let major = Int(components[0]) {
            self.major = major
        }
        
        if components.count > 1, let minor = Int(components[1]) {
            self.minor = minor
        }
        
        if components.count > 2, let patch = Int(components[2]) {
            self.patch = patch
        }
    }
}

extension Version : CustomStringConvertible {
    public var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
