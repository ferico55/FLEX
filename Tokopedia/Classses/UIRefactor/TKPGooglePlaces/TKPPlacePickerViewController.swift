//
//  TKPPlacePickerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/7/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

enum TypePlacePicker : Int{
    case TypeEditPlace
    case TypeShowPlace
}

@objc protocol TKPPlacePickerDelegate {
    func pickAddress(address: GMSAddress, suggestion:(String), longitude:Double, latitude:Double, mapImage:UIImage)
}

@objc class TKPPlacePickerViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var transparentView: UIView!
    @IBOutlet weak var mapView: TKPMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var whiteLocationView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var pinPointImageView: UIImageView!
    
    var delegate: TKPPlacePickerDelegate?
    var firstCoordinate = CLLocationCoordinate2D()
    var type : Int = 0
    var autoCompleteResults : [GMSAutocompletePrediction] = []
//    var autoCompleteResults : NSMutableArray = NSMutableArray()
    var placeHistories : NSMutableArray = NSMutableArray()
    
    var placePicker : GMSPlacePicker?
    var placesClient : GMSPlacesClient!

    var locationManager : CLLocationManager!
    var geocoder = GMSGeocoder()
    var address = GMSAddress()
    
    var shouldBeginEditing : Bool = true
    var isDragging :Bool = true
    var shouldStartSearch :Bool = false
    
    var captureScreen : UIImage = UIImage(named:"JakartaMap.png")!
    var dataTableView : [[String]] = [[],[]]
    var titleSection : [String] = ["Suggestions","Recent Search"]
    
    var selectedSugestion : String = ""

    override func loadView() {
        var className:NSString = NSStringFromClass(self.classForCoder)
        className = className.componentsSeparatedByString(".").last! as NSString
        NSBundle.mainBundle().loadNibNamed(className as String, owner:self, options:nil)
        
        whiteLocationView.layer.cornerRadius = 5
        doneButton = doneButton.roundCorners(UIRectCorner.TopRight.union(UIRectCorner.BottomRight), radius: 5)
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient()
        initLocationManager()
        adustBehaviorType(type)

        searchBar.placeholder = "Cari Alamat";
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.delegate = self

        loadHistory()
    }
    
    //MARK: View Action
    @IBAction func tapDone(sender: AnyObject) {
        let mapImage : UIImage = mapView.captureMapScreen()
        delegate?.pickAddress(address, suggestion: selectedSugestion, longitude: mapView.marker.position.longitude, latitude: mapView.marker.position.latitude, mapImage: mapImage)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // stop updating location in order to save battery power
        locationManager.stopUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        guard status != CLAuthorizationStatus.Denied else{
            return;
        }
        guard locationManager.location != nil && (firstCoordinate.longitude == 0 && firstCoordinate.latitude == 0) else{
            return;
        }
        mapView.updateCameraPosition(locationManager.location!.coordinate)
    }
    
    //MARK: - GMSMapView Delegate
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if(type == TypePlacePicker.TypeEditPlace.rawValue){ mapView.selectedMarker.position = position.target}
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        if(type == TypePlacePicker.TypeEditPlace.rawValue){updateAddressSaveHistory(false, addressSugestion: nil)}
    }
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        return self.mapView.infoWindowView;
    }
    
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        if (locationManager.location != nil){
            self.mapView.updateCameraPosition((locationManager.location?.coordinate)!)
        }
        return true
    }

    //MARK: - Methods
    func adustBehaviorType(type: Int){
        switch type {
        case TypePlacePicker.TypeEditPlace.rawValue :
            let doneBarButton = UIBarButtonItem(title: "Selesai", style: .Plain, target: self, action: "tapDone:")
            doneBarButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = doneBarButton
            self.title = "Pilih Lokasi"
            locationView.hidden = false
            pinPointImageView.hidden = false
            mapView.updateIsShowMarker(false)
            mapView.myLocationEnabled = true;
            if (firstCoordinate.longitude == 0 && locationManager.location != nil) {
                firstCoordinate =  locationManager.location!.coordinate
            }
            break;
        case TypePlacePicker.TypeShowPlace.rawValue:
            self.title = "Lokasi"
            searchBar.hidden = true
            searchBar.hidden = true
            mapView.updateIsShowMarker(true)
            mapView.updateCameraPosition(firstCoordinate)
            locationView.hidden = true
            pinPointImageView.hidden = true
            break;
            
        default:
            break;
        }
        mapView.updateCameraPosition(firstCoordinate)
        self.updateAddressSaveHistory(false, addressSugestion:nil)
    }
    
    func updateAddressSaveHistory(shouldSaveHistory : Bool, addressSugestion:GMSAutocompletePrediction?)
    {
        geocoder.reverseGeocodeCoordinate(mapView.selectedMarker.position) { (response, error) -> Void in
            if (error != nil){
                return
            }
            
            if (response != nil){
                let placemark :GMSAddress = response.firstResult()
                
                self.address = placemark
                self.addressLabel.setCustomAttributedText(self.addressString(placemark))
                self.mapView.updateAddress(self.addressString(placemark))
                self.mapView.selectedMarker = self.mapView.selectedMarker
                if (shouldSaveHistory) {
                    self.saveHistory(placemark, addressSuggestions: addressSugestion!)
                }
            }
        }
    }
    
    func loadHistory()
    {
        var destinationPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        destinationPath += "history_places.plist"
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(destinationPath) {
            print("File exists")
            do {
                let histories = try NSArray(contentsOfFile: destinationPath)!
                placeHistories.addObjectsFromArray(histories as [AnyObject])
                self.dataTableView[1] = []
                for var index = 0; index < self.placeHistories.count; ++index{
                    self.dataTableView[1].insert(placeHistories[index]["addressSugestion"] as! String, atIndex: index)
                }
                // the above prints "some text"
            } catch let error as NSError {
                print("Error: \(error)")
            }
        } else {
        }

    }
    
    func addressString(address:GMSAddress)-> String{
        var strSnippet : String = " "
        
        if (address.lines.count>0) {
            strSnippet = address.lines[0] as! String;
        }
        else{
            strSnippet = adjustStrSnippet(address.thoroughfare, strSnippet: strSnippet)
        }
        strSnippet = adjustStrSnippet(address.locality, strSnippet: strSnippet)
        strSnippet = adjustStrSnippet(address.subLocality, strSnippet: strSnippet)
        strSnippet = adjustStrSnippet(address.administrativeArea, strSnippet: strSnippet)
        strSnippet = adjustStrSnippet(address.postalCode, strSnippet: strSnippet)
        
        return strSnippet
    }
    
    func adjustStrSnippet(address : String?, strSnippet: String) -> String
    {
        var strSnippet : String = strSnippet
        if (address != nil){
            if (!strSnippet.isEmpty){
                strSnippet = "\(strSnippet), \(address!)"
            } else {
                strSnippet = address!;
            }
        }
        return strSnippet;
    }
    
    func saveHistory (address :GMSAddress, addressSuggestions :GMSAutocompletePrediction)
    {
        var documentsPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        documentsPath += "history_places.plist"
        
        var addressString : String!
        if (address.lines.count>0){
            addressString = address.lines[0] as! String
        }
        else{
            addressString = address.thoroughfare
        }
        
        var postalCode : String!
        if (address.postalCode == nil){ postalCode = ""} else{ postalCode = address.postalCode}
        
        let history: [String: AnyObject]! = ["addressSugestion"   :addressSuggestions.attributedFullText.string,
            "address"            :addressString,
            "postal_code"        :postalCode,
            "place_id"           :addressSuggestions.placeID!,
            "longitude"          :address.coordinate.longitude,
            "latitude"           :address.coordinate.latitude
        ]
        let array : Array = dataTableView[1] as Array
        if(array.contains(history["addressSugestion"] as! String) == false)
        {
            placeHistories.insertObject(history, atIndex: 0)
            placeHistories.writeToFile(documentsPath, atomically: true)
        }
    }
    
    func handleSearchForSearchString(searchString:String){
        let visibleRegion : GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds : GMSCoordinateBounds = GMSCoordinateBounds.init(coordinate: visibleRegion.farLeft, coordinate:visibleRegion.nearRight)
        let filter : GMSAutocompleteFilter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        
        placesClient?.autocompleteQuery(searchString, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
            if (error != nil){
                return
            }
            if(results?.count > 0){
                self.autoCompleteResults = results as! Array
                self.dataTableView[0]=[]
                for var index = 0; index < self.autoCompleteResults.count; ++index{
                    let place :GMSAutocompletePrediction = results![index] as! GMSAutocompletePrediction
                    self.dataTableView[0].insert(place.attributedFullText.string, atIndex: index)
                }
                
                self.tableView.hidden = false
                self.tableView.reloadData()
            }
        })
    }
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataTableView.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTableView[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "reuseIdentifier")
        
        cell.textLabel!.font = UIFont (name: "GothamBook", size: 13);
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.setCustomAttributedText(dataTableView[indexPath.section][indexPath.row])
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleSection[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        setSearchBarActive(false, animated: true)
        
        if (indexPath.section == 0) {
            doGeneratePlaceDetail(autoCompleteResults[indexPath.row].placeID, addressSuggestion: autoCompleteResults[indexPath.row])
        } else {
            let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake(placeHistories[indexPath.row]["latitude"] as! Double, placeHistories[indexPath.row]["longitude"] as! Double)
            mapView.updateCameraPosition(coordinate)
        }
        
        selectedSugestion = dataTableView[indexPath.section][indexPath.row]
        loadHistory()
    }

    //MARK: - Place Detail Request
    func doGeneratePlaceDetail(placeID:String, addressSuggestion:(GMSAutocompletePrediction))
    {
        placesClient?.lookUpPlaceID(placeID, callback: { (result, error) -> Void in
            if (error != nil){
                return;
            }
            
            if (result != nil) {
                let c2D : CLLocationCoordinate2D = CLLocationCoordinate2DMake((result?.coordinate.latitude)!, (result?.coordinate.longitude)!)
                self.mapView.updateCameraPosition(c2D)
                self.updateAddressSaveHistory(true, addressSugestion: addressSuggestion)
            } else {
                print("No place detail for \(placeID)")
            }
        })
    }
    
    //MARK: - SearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if((searchBar.text?.isEmpty) != nil){
            dataTableView[0].removeAll()
            tableView.reloadData()
        }
        handleSearchForSearchString(searchBar.text!)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if (searchBar.text == ""){
            dataTableView[0] = []
            tableView.reloadData()
        }

        setSearchBarActive(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        setSearchBarActive(false, animated: true)
    }
    
    func setSearchBarActive(isActive:Bool, animated:Bool)
    {
        searchBar.setShowsCancelButton(isActive, animated: animated)
        self.navigationController?.setNavigationBarHidden(isActive, animated: animated)
        UIApplication.sharedApplication().setStatusBarHidden(isActive, withAnimation: UIStatusBarAnimation.Slide)
        transparentView.hidden = !isActive
        
        if (animated){
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.activeSearchBar(isActive)
                if (!isActive){
                    self.searchBar.resignFirstResponder()
                }
            }, completion: nil)
        } else {
            activeSearchBar(isActive)
            if (!isActive){
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func activeSearchBar(isActive: Bool)
    {
        searchBar.frame = CGRectMake(0, 0, searchBar.frame.size.width, searchBar.frame.size.height)
        tableView.hidden = !(isActive && (dataTableView[0].count>0 || dataTableView[1].count>0))
    }
    
}
