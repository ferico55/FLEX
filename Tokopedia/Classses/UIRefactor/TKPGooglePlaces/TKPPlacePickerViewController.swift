//
//  TKPPlacePickerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/7/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit
import GoogleMaps

var _firstCoordinate = CLLocationCoordinate2D()

class TKPPlacePickerViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var _autoCompleteResults : [GMSAutocompletePrediction] = []
//    var _autoCompleteResults : NSMutableArray = []
    var _placeHistories : NSMutableArray = []
    
    var _placePicker = GMSPlacePicker()
    var _placesClient = GMSPlacesClient()
    var _marker = GMSMarker()
    var _locationManager = CLLocationManager()
    var _geoCode = GMSGeocoder()
    var _address = GMSAddress()
    
    var _shouldBeginEditing : Bool = true
    var _isDragging :Bool = true
    var _shouldStartSearch :Bool = false
    
    var _captureScreen : UIImage = UIImage(named:"")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _marker.position = _firstCoordinate
        _marker.map = mapView;
        _marker.appearAnimation = kGMSMarkerAnimationNone;
        _marker.icon = UIImage(named:"icon_pinpoin_toped.png")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
