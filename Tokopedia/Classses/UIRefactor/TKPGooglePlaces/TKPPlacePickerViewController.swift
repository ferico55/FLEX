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

@objc class TKPAddressStreet : NSObject {
    
    func getStreetAddress(street : String)->String{
        let str = street
        let streetNumber = str.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        print(streetNumber)
        
        var address = street
        var hasValue = false
        
        // Loops thorugh the street
        for i in street.characters {
            let str = String(i)
            // Checks if the char is a number
            if (Int(str) != nil){
                // If it is it appends it to number
                address = address.stringByReplacingOccurrencesOfString(str, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                // Here we set the hasValue to true, beacause the street number will come in one order
                // 531 in this case
                hasValue = true
            }
            else{
                // Lets say that we have runned through 531 and are at the blank char now, that means we have looped through the street number and can end the for iteration
                if(hasValue){
                    break
                }
            }
        }
        address = address.stringByReplacingOccurrencesOfString("Kav", withString: "")
        address = address.stringByReplacingOccurrencesOfString("-", withString: "")
        return address
    }
    
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
    
    @IBOutlet var infoAddressView: UIView!
    
    @IBOutlet var receiverNumberLabel: UILabel!
    @IBOutlet var addressStreetLabel: UILabel!
    @IBOutlet var receiverNameLabel: UILabel!
    @IBOutlet var addressNameLabel: UILabel!
    
    @IBOutlet var infoViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet var transparantInfoView: UIView!
    @IBOutlet weak var mapWarningLabel: UILabel!
    
    var delegate: TKPPlacePickerDelegate?
    var firstCoordinate = CLLocationCoordinate2D()
    var type : Int = 0
    var autoCompleteResults : [GMSAutocompletePrediction] = []
    var placeHistories : NSMutableArray = NSMutableArray()
    
    var placePicker : GMSPlacePicker?
    var placesClient : GMSPlacesClient!

    var locationManager : CLLocationManager!
    var geocoder = GMSGeocoder()
    var address = GMSAddress()
    
    var shouldBeginEditing : Bool = true
    var isDragging :Bool = true
    var shouldStartSearch :Bool = false
    
    var captureScreen : UIImage = UIImage(named:"map_gokil.png")!
    var dataTableView : [[String]] = [[],[]]
    var titleSection : [String] = ["Suggestions","Recent Search"]
    
    var selectedSugestion : String = ""
    
    var _previousY:CGFloat!
    var _infoTopConstraint:NSLayoutConstraint!

    var infoAddress : AddressViewModel!

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
        loadHistory()
        createWarningLabel()
    }
    
    //MARK: - View Action
    @IBAction func tapDone(sender: AnyObject) {
        let mapImage : UIImage = mapView.captureMapScreen()
        delegate?.pickAddress(address, suggestion: selectedSugestion, longitude: mapView.marker.position.longitude, latitude: mapView.marker.position.latitude, mapImage: mapImage)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func tapTransparantInfoView(sender: AnyObject) {
        hideInfo()
    }
    
    @IBAction func tapTransparentSearchBar(sender: AnyObject) {
        setSearchBarActive(false, animated: true)
    }
    
    @IBAction func tapShowInfoAddress(sender: AnyObject) {
        if(_infoTopConstraint.constant <= -60){
            infoViewConstraintHeight.constant = receiverNumberLabel.frame.origin.y + receiverNumberLabel.frame.size.height + 20
            showInfo()
        }
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
        self.addressLabel.setCustomAttributedText("Tandai lokasi Anda")
        self.mapView.updateAddress("Tandai lokasi Anda")
    }
    
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        if(type == TypePlacePicker.TypeEditPlace.rawValue){
            if(position != nil && mapView.selectedMarker != nil){
                mapView.selectedMarker.position = position.target
                updateAddressSaveHistory(false, addressSugestion: nil)
            }
        }
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
    
    func createWarningLabel() -> Void {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        let font = UIFont(name: "GothamLight", size: 10.0)!
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:style]
        let string = "Pastikan lokasi yang Anda tandai di peta sesuai dengan alamat Anda di atas"
        let attributedString = NSMutableAttributedString(string:string, attributes:attributes)
        self.mapWarningLabel.attributedText = attributedString;
    }
    
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
            mapView.myLocationEnabled = true
            if (firstCoordinate.longitude == 0 && firstCoordinate.latitude == 0 && locationManager.location != nil) {
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
            mapView.showButtonCurrentLocation(false)
            break;
            
        default:
            break;
        }
        mapView.updateCameraPosition(firstCoordinate)
        self.updateAddressSaveHistory(false, addressSugestion:nil)
        searchBar.placeholder = "Cari Alamat";
        searchBar.tintColor = UIColor.whiteColor()
        searchBar.delegate = self
        searchBar.setBackgroundImage(UIImage(named: "NavBar"), forBarPosition: .Top, barMetrics: .Default)
        if((infoAddress) != nil){
            _infoTopConstraint = NSLayoutConstraint(
                item: self.infoAddressView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: -60.0)
            self.view .addConstraint(_infoTopConstraint)
            mapView.padding = UIEdgeInsetsMake(searchBar.frame.size.height, 0.0, abs(_infoTopConstraint.constant), 0.0);
            adjustInfoAddress(infoAddress)
        }
        else
        {
            _infoTopConstraint = NSLayoutConstraint(
                item: self.infoAddressView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0)
            self.view .addConstraint(_infoTopConstraint)
            mapView.padding = UIEdgeInsetsMake(searchBar.frame.size.height, 0.0, 0.0, 0.0);

        }
    }
    
    func adjustInfoAddress(address:AddressViewModel) {
        receiverNumberLabel.setCustomAttributedText(address.receiverNumber)
        receiverNumberLabel.sizeToFit()
        addressStreetLabel.setCustomAttributedText("\(address.addressStreet)\n\(address.addressDistrict),\n\(address.addressCity),\n\(address.addressProvince), \(address.addressCountry) \(address.addressPostalCode)")
        addressStreetLabel.sizeToFit()
        receiverNameLabel.setCustomAttributedText(address.receiverName)
        receiverNameLabel.sizeToFit()
        addressNameLabel.setCustomAttributedText(address.addressName)
        addressNameLabel.sizeToFit()

    }
    
    @IBAction func panInfoAddress(gestureRecognizer: UIPanGestureRecognizer) {
        infoViewConstraintHeight.constant = receiverNumberLabel.frame.origin.y + receiverNumberLabel.frame.size.height + 20

        let touchPoint: CGPoint = gestureRecognizer.locationInView(self.view)
        switch (gestureRecognizer.state){
        case .Began:
            break
        case .Changed:
            let delta:CGFloat = touchPoint.y - _previousY
            _infoTopConstraint.constant+=delta
            break
        case .Failed, .Cancelled, .Ended:
            let yVelocity:CGFloat = gestureRecognizer.velocityInView(gestureRecognizer.view).y
            if (abs(yVelocity) > 50) {
                if (yVelocity > 0) {
                    hideInfo()
                } else {
                    showInfo()
                }
            } else if (infoAddressView.frame.origin.y < (self.view.frame.size.height-infoAddressView.frame.size.height+infoAddressView.frame.size.height/2)) {
                showInfo()
            } else {
                hideInfo()
            }
            break
        default: break
        }
        _previousY = touchPoint.y;
        
    }
    
    func hideInfo() -> Void{
        transparantInfoView.hidden = true
        _infoTopConstraint.constant = -60
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                
        }
    }
    
    func showInfo() -> Void{
        transparantInfoView.hidden = false
        _infoTopConstraint.constant = -infoViewConstraintHeight.constant
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                
        }
    }
    
    func updateAddressSaveHistory(shouldSaveHistory : Bool, addressSugestion:GMSAutocompletePrediction?)
    {
        self.addressLabel.setCustomAttributedText("Tandai lokasi Anda")
        self.mapView.updateAddress("Tandai lokasi Anda")
        geocoder.reverseGeocodeCoordinate(mapView.selectedMarker.position) { (response, error) -> Void in
            if (error != nil){
                return
            }
            
            if (response != nil && response.results().count > 0){
                let placemark :GMSAddress = response.firstResult()
                
                self.address = placemark
                self.addressLabel.setCustomAttributedText(self.addressString(placemark))
                self.mapView.updateAddress(self.addressString(placemark))
                self.mapView.selectedMarker = self.mapView.selectedMarker
                if (shouldSaveHistory && addressSugestion != nil) {
                    self.saveHistory(placemark, addressSuggestions: addressSugestion!)
                }
            }else {
                self.addressLabel.setCustomAttributedText("Tandai lokasi Anda")
                self.mapView.updateAddress("Tandai lokasi Anda")
                self.mapView.selectedMarker = self.mapView.selectedMarker
            }
        }
    }
    
    func loadHistory()
    {
        var destinationPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        destinationPath += "/history_places.plist"
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(destinationPath) {
            print("File exists")
            do {
                let histories = try NSArray(contentsOfFile: destinationPath)!
                placeHistories.removeAllObjects()
                placeHistories.addObjectsFromArray(histories as [AnyObject])
                self.dataTableView[1] = []
                for var index = 0; index < self.placeHistories.count-1; ++index{
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
        var strSnippet : String = ""
        //MARK:: IBR-372 PO Wishes
        if (address.thoroughfare != nil) {
            strSnippet = TKPAddressStreet().getStreetAddress(address.thoroughfare)
        }
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
    
    func saveHistory (address :GMSAddress, addressSuggestions :GMSAutocompletePrediction?)
    {
        var documentsPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        documentsPath += "/history_places.plist"
        
        let addressString : String = TKPAddressStreet().getStreetAddress(address.thoroughfare)
        
        var postalCode : String!
        if (address.postalCode == nil){ postalCode = ""} else{ postalCode = address.postalCode}
        
        var addressSugestionString:String = " "
        var placeID: String = " "
        var longitude: Double = 0
        var latitude: Double = 0
        if (addressSuggestions != nil){
            addressSugestionString = addressSuggestions!.attributedFullText.string
            placeID = addressSuggestions!.placeID!
            longitude = address.coordinate.longitude
            latitude = address.coordinate.latitude
        }
        
        let history: [String: AnyObject]! = [
            "addressSugestion"   :addressSugestionString,
            "address"            :addressString,
            "postal_code"        :postalCode,
            "place_id"           :placeID,
            "longitude"          :longitude,
            "latitude"           :latitude
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
                for var index = 0; index < self.autoCompleteResults.count-1; ++index{
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
