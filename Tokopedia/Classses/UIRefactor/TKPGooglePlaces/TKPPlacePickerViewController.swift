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

@objc class TKPPlacePickerViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var transparentView: UIView!
    @IBOutlet weak var mapView: TKPMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var whiteLocationView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var firstCoordinate = CLLocationCoordinate2D()
    internal var type : Int = 0
//    var autoCompleteResults : [GMSAutocompletePrediction] = []
    var autoCompleteResults : NSMutableArray = NSMutableArray()
    var placeHistories : NSMutableArray = NSMutableArray()
    
    var placePicker : GMSPlacePicker?
    var placesClient : GMSPlacesClient?

    var locationManager : CLLocationManager!
    var geocoder = GMSGeocoder()
    var address = GMSAddress()
    
    var shouldBeginEditing : Bool = true
    var isDragging :Bool = true
    var shouldStartSearch :Bool = false
    
    var captureScreen : UIImage = UIImage(named:"icon_pinpoin_toped.png")!
    var titleArrayTableView : [[String]] = []

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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLocationManager()
        adustBehaviorType(type)

        searchBar.placeholder = "Cari Alamat";
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.delegate = self

        loadHistory()
        titleArrayTableView[0] += ["Suggestions","Recent Search"]
    }
    
    //MARK: View Action
    @IBAction func tapDone(sender: AnyObject) {
        
//        UIImage *map = _captureScreen?:[PlacePickerViewController captureScreen:mapView];
//        [_delegate PickAddress:_address suggestion:_selectedSugestion?:@"" longitude:marker.position.longitude latitude:marker.position.latitude map:map];
//        
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // stop updating location in order to save battery power
        locationManager.stopUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied){
            
        }
        else{
            mapView.marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)//locationManager.location!.coordinate
            mapView.updateCameraPosition()
        }
    }
    
    //MARK: - GMSMapView Delegate
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        mapView.selectedMarker.position = position.target
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        updateAddressSaveHistory(false, addressSugestion: nil)
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
            mapView.isShowMarker = false
            mapView.myLocationEnabled = true;
            if (firstCoordinate.longitude == 0) {
                firstCoordinate =  CLLocationCoordinate2DMake(-33.86, 151.20)//locationManager.location!.coordinate
            }
            break;
        case TypePlacePicker.TypeShowPlace.rawValue:
            self.title = "Lokasi"
            searchBar.hidden = true
            searchBar.hidden = true
            mapView.isShowMarker = true
            break;
            
        default:
            break;
        }
    }
    
    func updateAddressSaveHistory(shouldSaveHistory : Bool, addressSugestion:GMSAutocompletePrediction?)
    {
        geocoder .reverseGeocodeCoordinate(mapView.selectedMarker.position) { (response, error) -> Void in
            // strAdd -> take bydefault value nil
            let placemark :GMSAddress = response.firstResult()
            
            self.address = placemark
            self.mapView.infoWindowView.addressLabel.setCustomAttributedText(self.addressString(placemark))
            self.addressLabel.setCustomAttributedText(self.addressString(placemark))
            self.mapView.selectedMarker = self.mapView.selectedMarker
            if (shouldSaveHistory) {
                self.saveHistory(placemark, addressSuggestions: addressSugestion!)
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
//                let histories = try NSArray(contentsOfFile: destinationPath)!
                    placeHistories.addObjectsFromArray(histories as [AnyObject])
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
        
        let history: [String: AnyObject]! = ["addressSugestion"   :addressSuggestions.attributedFullText.string,
            "address"            :addressString,
            "postal_code"        :address.postalCode,
            "locality"           :address.locality,
            "subLocality"        :address.subLocality,
            "administrativeArea" :address.administrativeArea,
            "country"            :address.country,
            "place_id"           :addressSuggestions.placeID,
            "longitude"          :address.coordinate.longitude,
            "latitude"           :address.coordinate.latitude
        ]
        if(!placeHistories.containsObject(history))
        {
            placeHistories.insertObject(history, atIndex: 0)
            placeHistories.writeToFile(documentsPath, atomically: true)
        }
    }
    
    func focusMapToLocation(location: CLLocationCoordinate2D, isShouldUpdateAddress:Bool, saveHistory: Bool, addressSugestion: GMSAutocompletePrediction)
    {
        mapView.marker.position = location
        mapView.updateCameraPosition()
        
        if(isShouldUpdateAddress){
            updateAddressSaveHistory(saveHistory, addressSugestion: addressSugestion)
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
                self.autoCompleteResults.removeAllObjects()
                self.autoCompleteResults.addObject(results!)
                self.titleArrayTableView[1].removeAll()
                for var index = 0; index < self.autoCompleteResults.count; ++index{
                    let place :GMSAutocompletePrediction = results![index] as! GMSAutocompletePrediction
                    self.titleArrayTableView[1][index] += place.attributedFullText.string
                }
                
                self.tableView.hidden = false
                self.tableView.reloadData()
            }
        })
    }
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titleArrayTableView.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleArrayTableView[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        cell.textLabel!.font = UIFont (name: "GothamBook", size: 13);
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.setCustomAttributedText(titleArrayTableView[indexPath.section][indexPath.row])
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleArrayTableView[0][section]
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
                self.focusMapToLocation(c2D, isShouldUpdateAddress: true, saveHistory: true, addressSugestion: addressSuggestion)
            } else {
                print("No place detail for \(placeID)")
            }
        })
    }
    
    //MARK: - SearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if((searchBar.text?.isEmpty) != nil){
            titleArrayTableView[1].removeAll()
            tableView.reloadData()
        }
        handleSearchForSearchString(searchBar.text!)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if ((searchBar.text?.isEmpty) != nil){
            titleArrayTableView[1].removeAll()
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
        tableView.hidden = !(isActive && placeHistories.count>0 )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
