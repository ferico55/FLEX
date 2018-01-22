//
//  ReactLocationServiceManager.swift
//  Tokopedia
//
//  Created by Sigit Hanafi on 1/12/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import CoreLocation
import React

@objc(ReactLocationServiceManager)
class ReactLocationServiceManager: NSObject {
    var bridge: RCTBridge!
    
    @objc func getLocationServiceStatus(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let dict = ["locationServiceEnabled": true, "locationServicePermission": false]
                resolve(dict)
            case .authorizedAlways, .authorizedWhenInUse:
                let dict = ["locationServiceEnabled": true, "locationServicePermission": true]
                resolve(dict)
            }
        } else {
            let dict = ["locationServiceEnabled": false, "locationServicePermission": false]
            resolve(dict)
        }
    }
}
