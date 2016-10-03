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
        marker.infoWindowAnchor = CGPointMake(0.45, 0.0);
        self.selectedMarker = marker

        self.myLocationEnabled = true
        self.settings.myLocationButton = true
    }
    
    func updateIsShowMarker(isShowMarker: Bool){
        self.isShowMarker = isShowMarker
        if (isShowMarker){
            marker.opacity = 1.0
            infoWindowView.hidden = false
        }
        else{
            marker.opacity = 0.0
            infoWindowView.hidden = true
        }
    }
    
    func showButtonCurrentLocation(isShow : Bool){
        self.settings.myLocationButton = isShow;
    }
    
    func updateCameraPosition (position:CLLocationCoordinate2D) {
        marker.position = position
        self.selectedMarker = marker
        cameraUpdate = GMSCameraUpdate.setTarget(self.projection.coordinateForPoint(self.projection.pointForCoordinate(marker.position)))
        self.animateWithCameraUpdate(cameraUpdate)
        cameraPosition = GMSCameraPosition.cameraWithLatitude(marker.position.latitude, longitude:marker.position.longitude, zoom: 16)
        self.camera = cameraPosition
    }
    
    func updateAddress(address:String){
        self.infoWindowView.addressLabel!.setCustomAttributedText(address)
    }
}
