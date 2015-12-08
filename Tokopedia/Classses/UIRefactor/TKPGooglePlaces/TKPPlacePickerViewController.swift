//
//  TKPPlacePickerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/7/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit
import GoogleMaps

enum TypePlacePicker : Int{
    case TypeEditPlace
    case TypeShowPlace
}

@objc class TKPPlacePickerViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var whiteLocationInfoView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var whiteLocationView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressInfoLabel: UILabel!
    
    var _firstCoordinate = CLLocationCoordinate2D()
    internal var _type : Int = 0
    var _autoCompleteResults : [GMSAutocompletePrediction] = []
//    var _autoCompleteResults : NSMutableArray = []
    var _placeHistories : [String] = []
//    var _placeHistories : NSMutableArray = NSMutableArray()
    
    var _placePicker : GMSPlacePicker?
    var _placesClient : GMSPlacesClient?
    var _marker = GMSMarker()
    var _locationManager = CLLocationManager()
    var _geocoder = GMSGeocoder()
    var _address = GMSAddress()
    
    var _shouldBeginEditing : Bool = true
    var _isDragging :Bool = true
    var _shouldStartSearch :Bool = false
    
    var _captureScreen : UIImage = UIImage(named:"icon_pinpoin_toped.png")!

    override func loadView() {
        var className:NSString = NSStringFromClass(self.classForCoder)
        className = className.componentsSeparatedByString(".").last! as NSString
        NSBundle.mainBundle().loadNibNamed(className as String, owner:self, options:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 8.0, *) {
            _locationManager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        _locationManager.startUpdatingHeading()
        _locationManager.delegate = self;
        adustBehaviorType(_type)

        _marker.map = mapView;
        _marker.appearAnimation = kGMSMarkerAnimationNone;
        _marker.icon = UIImage(named:"icon_pinpoin_toped.png")
        
        _marker.position = _firstCoordinate
        
        searchBar.placeholder = "Cari Alamat";
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.delegate = self
        
        mapView.selectedMarker = _marker
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithTarget(_marker.position, zoom: 16)
        mapView.camera = camera;
        
        whiteLocationView.layer.cornerRadius = 5
        doneButton = doneButton.roundCorners(UIRectCorner.TopRight.union(UIRectCorner.BottomRight), radius: 5)
        whiteLocationView.layer.cornerRadius = 5;
        
        updateAddressSaveHistory(false, addressSugestion: nil)
        loadHistory()
    }
    
    func adustBehaviorType(type: Int){
        switch type {
        case TypePlacePicker.TypeEditPlace.rawValue :
            let doneBarButton = UIBarButtonItem(title: "Selesai", style: .Plain, target: self, action: "tapDone:")
            doneBarButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = doneBarButton
            self.title = "Pilih Lokasi"
            locationView.hidden = false
            _marker.opacity = 0.0
            mapView.myLocationEnabled = true;
            if (_firstCoordinate.longitude == 0) {
                _firstCoordinate = (_locationManager.location?.coordinate)!
            }
            break;
        case TypePlacePicker.TypeShowPlace.rawValue:
            self.title = "Lokasi"
            searchBar.hidden = true
            searchBar.hidden = true
            _marker.opacity = 1.0
            break;
            
        default:
            break;
        }
    }
    
    func updateAddressSaveHistory(shouldSaveHistory : Bool, addressSugestion:GMSAutocompletePrediction?)
    {
        _geocoder .reverseGeocodeCoordinate(_marker.position) { (response, error) -> Void in
            // strAdd -> take bydefault value nil
            let placemark :GMSAddress = response.firstResult()
            
            self._address = placemark
            self.addressLabel.setCustomAttributedText(self.addressString(placemark))
            self.addressInfoLabel.setCustomAttributedText(self.addressString(placemark))
            self.mapView.selectedMarker = self._marker
            if (shouldSaveHistory) {
                self.saveHistory(placemark, addressSuggestions: addressSugestion!)
            }
        }
    }
    
    func loadHistory()
    {
        var documentsPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        documentsPath += "history_places.plist"
        let rawStandards: NSArray = NSArray(contentsOfFile: documentsPath)!
        _placeHistories = [String](arrayLiteral: rawStandards as! [_,])
        _placeHistories.addObjectsFromArray(rawStandards as [AnyObject])
    }
    
    func addressString(address:GMSAddress)-> String{
        var strSnippet : String = "asd"
        
        if (address.lines.count>0) {
            strSnippet = address.lines[0] as! String;
        }
        else
        {
            if (!address.thoroughfare.isEmpty)
            {
                if (!strSnippet.isEmpty)
                {
                    strSnippet = "\(strSnippet), \(address.thoroughfare)"
                }
                else
                {
                    strSnippet = address.thoroughfare;
                }
            }
        }
        
        if (!address.locality.isEmpty)
        {
            if (!strSnippet.isEmpty)
            {
                strSnippet = "\(strSnippet),\(address.locality)"
            }
            else
            {
                strSnippet = address.locality;
            }
        }
        
        if (!address.subLocality.isEmpty)
        {
            if (!strSnippet.isEmpty)
            {
                strSnippet = "\(strSnippet),\(address.subLocality)"
            }
            else
            {
                strSnippet = address.subLocality;
            }
        }
        
        if (!address.administrativeArea.isEmpty)
        {
            if (!strSnippet.isEmpty)
            {
                strSnippet = "\(strSnippet),\(address.administrativeArea)"
            }
            else
            {
                strSnippet = address.administrativeArea;
            }
        }
        
        if (!address.postalCode.isEmpty)
        {
            if (!strSnippet.isEmpty)
            {
                strSnippet = "\(strSnippet),\(address.postalCode)"
            }
            else
            {
                strSnippet = address.postalCode;
            }
        }
        
        return strSnippet
    }
    
    func saveHistory (address :GMSAddress, addressSuggestions :GMSAutocompletePrediction)
    {
        
    }
    
    @IBAction func tapDone(sender: AnyObject) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
