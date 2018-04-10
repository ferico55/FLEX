//
//  MapViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 16/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import CoreLocation
import NativeNavigation
import UIKit

internal class MapViewController: ReactViewController {
    internal var onLocationSelected: ((String, CLLocationCoordinate2D) -> Void)?
    
    @objc
    internal init(coordinate: CLLocationCoordinate2D, districtId: String?, postalCode: String?, onLocationSelected: @escaping ((String, CLLocationCoordinate2D) -> Void)) {
        self.onLocationSelected = onLocationSelected
        
        super.init(moduleName: "PinpointMapView", props: [
            "district": [
                "id": districtId ?? "",
                "postalCode": postalCode ?? ""
            ] as AnyObject,
            "location": [
                "isLoading": true,
                "coordinate": [
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude
                ] as AnyObject
            ] as AnyObject
            ])
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    internal override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidSelected(_:)), name: NSNotification.Name(rawValue: "LocationDidSelected"), object: nil)
    }
    
    internal func locationDidSelected(_ notification: Notification) {
        guard let instanceId = notification.userInfo?["nativeNavigationInstanceId"] as? String else {
            return
        }
        
        if instanceId != nativeNavigationInstanceId {
            return
        }
        
        let districtName = notification.userInfo?["name"] as? String
        let latitude = (notification.userInfo?["coordinate"] as? [String: Double])?["latitude"]
        let longitude = (notification.userInfo?["coordinate"] as? [String: Double])?["longitude"]
        
        self.onLocationSelected?(districtName ?? "", CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
