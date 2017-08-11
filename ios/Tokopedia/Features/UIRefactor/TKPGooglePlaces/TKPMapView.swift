//
//  TKPMapView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit
import GoogleMaps

@IBDesignable
class TKPMapView: GMSMapView {

    var marker = GMSMarker()
    var position = CLLocationCoordinate2D()
    var isShowMarker : Bool = true
    var cameraUpdate : GMSCameraUpdate!
    var cameraPosition : GMSCameraPosition!
    var infoWindowView : TKPInfoWindowMapView = TKPInfoWindowMapView()
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        infoWindowView = infoWindowView.newView() as! TKPInfoWindowMapView
        infoWindowView.whiteLocationInfoView!.layer.cornerRadius = 5

        marker.map = self;
        marker.icon = UIImage(named:"icon_pinpoin_toped.png")
        marker.infoWindowAnchor = CGPoint(x: 0.45, y: 0.0);
        self.selectedMarker = marker

        self.isMyLocationEnabled = true
        self.settings.myLocationButton = true
    }
    
    func updateIsShowMarker(_ isShowMarker: Bool){
        self.isShowMarker = isShowMarker
        if (isShowMarker){
            marker.opacity = 1.0
            infoWindowView.isHidden = false
        }
        else{
            marker.opacity = 0.0
            infoWindowView.isHidden = true
        }
    }
    
    func showButtonCurrentLocation(_ isShow : Bool){
        self.settings.myLocationButton = isShow;
    }
    
    func updateCameraPosition (_ position:CLLocationCoordinate2D) {
        marker.position = position
        self.selectedMarker = marker
        cameraUpdate = GMSCameraUpdate.setTarget(self.projection.coordinate(for: self.projection.point(for: marker.position)))
        self.animate(with: cameraUpdate)
        cameraPosition = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude:marker.position.longitude, zoom: 16)
        self.camera = cameraPosition
    }
    
    func updateAddress(_ address:String){
        self.infoWindowView.addressLabel!.setCustomAttributedText(address)
    }
}
