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
class TKPMapView: GMSMapView, GMSMapViewDelegate {

    var marker = GMSMarker()
    var position = CLLocationCoordinate2D()
    var isShowMarker : Bool = true
    var cameraUpdate : GMSCameraUpdate!
    var cameraPosition : GMSCameraPosition!
    var infoWindowView : TKPInfoWindowMapView = TKPInfoWindowMapView()
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        infoWindowView = TKPInfoWindowMapView()
        
        marker.map = self;
        marker.appearAnimation = kGMSMarkerAnimationNone
        marker.icon = UIImage(named:"icon_pinpoin_toped.png")
        self.selectedMarker = marker

        self.myLocationEnabled = true

        self.myLocationEnabled = true
        self.settings.myLocationButton = true;
        updateCameraPosition(position)
        self .addSubview(infoWindowView)
    }
    
    func updateIsShowMarker(isShowMarker: Bool){
        self.isShowMarker = isShowMarker
        if (isShowMarker){
            marker.opacity = 1.0
        }
        else{
            marker.opacity = 0.0
        }
    }
    
    func updateCameraPosition (position:CLLocationCoordinate2D) {
        marker.position = position
        self.selectedMarker = marker
        cameraUpdate = GMSCameraUpdate.setTarget(self.projection.coordinateForPoint(self.projection.pointForCoordinate(marker.position)))
        self.animateWithCameraUpdate(cameraUpdate)
        cameraPosition = GMSCameraPosition.cameraWithLatitude(marker.position.latitude, longitude:marker.position.longitude, zoom: 16)
        self.camera = cameraPosition
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        return infoWindowView;
    }

}
