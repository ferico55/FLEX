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


@objc public enum TypePlacePicker : Int{
    case typeEditPlace
    case typeShowPlace
}

@objc class TKPAddressStreet : NSObject {
    
    func getStreetAddress(_ street : String)->String{
        let str = street
        let streetNumber = str.components(
            separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        print(streetNumber)
        
        var address = street
        var hasValue = false
        
        // Loops thorugh the street
        for i in street.characters {
            let str = String(i)
            // Checks if the char is a number
            if (Int(str) != nil){
                // If it is it appends it to number
                address = address.replacingOccurrences(of: str, with: "", options: NSString.CompareOptions.literal, range: nil)
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
        address = address.replacingOccurrences(of: "Kav", with: "")
        address = address.replacingOccurrences(of: "-", with: "")
        return address
    }
    
}

@objc protocol TKPPlacePickerDelegate {
    func pickAddress(_ address: GMSAddress, suggestion:(String), longitude:Double, latitude:Double, mapImage:UIImage)
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
    var placeHistories = NSMutableArray()
    
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
        var className:NSString = NSStringFromClass(self.classForCoder) as NSString
        className = className.components(separatedBy: ".").last! as NSString
        Bundle.main.loadNibNamed(className as String, owner:self, options:nil)
        
        whiteLocationView.layer.cornerRadius = 5
        doneButton = doneButton.roundCorners(UIRectCorner.topRight.union(UIRectCorner.bottomRight), radius: 5)
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestAlwaysAuthorization()
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
    @IBAction func tapDone(_ sender: AnyObject) {
        let mapImage : UIImage = UIImage(named: "map_gokil.png")!
        delegate?.pickAddress(address, suggestion: selectedSugestion, longitude: mapView.marker.position.longitude, latitude: mapView.marker.position.latitude, mapImage: mapImage)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapTransparantInfoView(_ sender: AnyObject) {
        hideInfo()
    }
    
    @IBAction func tapTransparentSearchBar(_ sender: AnyObject) {
        setSearchBarActive(false, animated: true)
    }
    
    @IBAction func tapShowInfoAddress(_ sender: AnyObject) {
        if(_infoTopConstraint.constant <= -60){
            infoViewConstraintHeight.constant = receiverNumberLabel.frame.origin.y + receiverNumberLabel.frame.size.height + 20
            showInfo()
        }
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // stop updating location in order to save battery power
        locationManager.stopUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != CLAuthorizationStatus.denied else{
            return;
        }
        guard locationManager.location != nil && (firstCoordinate.longitude == 0 && firstCoordinate.latitude == 0) else{
            return;
        }
        mapView.updateCameraPosition(locationManager.location!.coordinate)
    }
    
    //MARK: - GMSMapView Delegate
    func mapView(_ mapView: GMSMapView!, didChange position: GMSCameraPosition!) {
        self.addressLabel.setCustomAttributedText("Tandai lokasi Anda")
        self.mapView.updateAddress("Tandai lokasi Anda")
    }
    
    func mapView(_ mapView: GMSMapView!, willMove gesture: Bool) {
    }
    
    func mapView(_ mapView: GMSMapView!, idleAt position: GMSCameraPosition!) {
        if(type == TypePlacePicker.typeEditPlace.rawValue){
            if(position != nil && mapView.selectedMarker != nil){
                mapView.selectedMarker.position = position.target
                updateAddressSaveHistory(false, addressSugestion: nil)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        return self.mapView.infoWindowView;
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView!) -> Bool {
        if (locationManager.location != nil){
            self.mapView.updateCameraPosition((locationManager.location?.coordinate)!)
        }
        return true
    }

    //MARK: - Methods
    
    func createWarningLabel() -> Void {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        let font = UIFont.microTheme()
        let attributes = [NSFontAttributeName:font, NSParagraphStyleAttributeName:style]
        let string = "Pastikan lokasi yang Anda tandai di peta sesuai dengan alamat Anda di atas"
        let attributedString = NSMutableAttributedString(string:string, attributes:attributes)
        self.mapWarningLabel.attributedText = attributedString;
    }
    
    func adustBehaviorType(_ type: Int){
        switch type {
        case TypePlacePicker.typeEditPlace.rawValue :
            let doneBarButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(TKPPlacePickerViewController.tapDone(_:)))
            doneBarButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = doneBarButton
            self.title = "Pilih Lokasi"
            locationView.isHidden = false
            pinPointImageView.isHidden = false
            mapView.updateIsShowMarker(false)
            mapView.isMyLocationEnabled = true
            if (firstCoordinate.longitude == 0 && firstCoordinate.latitude == 0 && locationManager.location != nil) {
                firstCoordinate =  locationManager.location!.coordinate
            }
            break;
        case TypePlacePicker.typeShowPlace.rawValue:
            self.title = "Lokasi"
            searchBar.isHidden = true
            searchBar.isHidden = true
            mapView.updateIsShowMarker(true)
            mapView.updateCameraPosition(firstCoordinate)
            locationView.isHidden = true
            pinPointImageView.isHidden = true
            mapView.showButtonCurrentLocation(false)
            break;
            
        default:
            break;
        }
        mapView.updateCameraPosition(firstCoordinate)
        self.updateAddressSaveHistory(false, addressSugestion:nil)
        searchBar.placeholder = "Cari Alamat";
        searchBar.tintColor = UIColor.white
        searchBar.delegate = self
        searchBar.setBackgroundImage(UIImage(named: "NavBar"), for: .top, barMetrics: .default)
        if((infoAddress) != nil){
            _infoTopConstraint = NSLayoutConstraint(
                item: self.infoAddressView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
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
                attribute: .top,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0)
            self.view .addConstraint(_infoTopConstraint)
            mapView.padding = UIEdgeInsetsMake(searchBar.frame.size.height, 0.0, 0.0, 0.0);

        }
    }
    
    func adjustInfoAddress(_ address:AddressViewModel) {
        receiverNumberLabel.setCustomAttributedText(address.receiverNumber)
        receiverNumberLabel.sizeToFit()
        addressStreetLabel.setCustomAttributedText("\(address.addressStreet)\n\(address.addressDistrict),\n\(address.addressCity),\n\(address.addressProvince), \(address.addressCountry) \(address.addressPostalCode)")
        addressStreetLabel.sizeToFit()
        receiverNameLabel.setCustomAttributedText(address.receiverName)
        receiverNameLabel.sizeToFit()
        addressNameLabel.setCustomAttributedText(address.addressName)
        addressNameLabel.sizeToFit()

    }
    
    @IBAction func panInfoAddress(_ gestureRecognizer: UIPanGestureRecognizer) {
        infoViewConstraintHeight.constant = receiverNumberLabel.frame.origin.y + receiverNumberLabel.frame.size.height + 20

        let touchPoint: CGPoint = gestureRecognizer.location(in: self.view)
        switch (gestureRecognizer.state){
        case .began:
            break
        case .changed:
            let delta:CGFloat = touchPoint.y - _previousY
            _infoTopConstraint.constant+=delta
            break
        case .failed, .cancelled, .ended:
            let yVelocity:CGFloat = gestureRecognizer.velocity(in: gestureRecognizer.view).y
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
        transparantInfoView.isHidden = true
        _infoTopConstraint.constant = -60
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                
        }
    }
    
    func showInfo() -> Void{
        transparantInfoView.isHidden = false
        _infoTopConstraint.constant = -infoViewConstraintHeight.constant
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                
        }
    }
    
    func updateAddressSaveHistory(_ shouldSaveHistory : Bool, addressSugestion:GMSAutocompletePrediction?)
    {
        self.addressLabel.setCustomAttributedText("Tandai lokasi Anda")
        self.mapView.updateAddress("Tandai lokasi Anda")
        geocoder.reverseGeocodeCoordinate(mapView.selectedMarker.position) { (response, error) -> Void in
            if (error != nil){
                return
            }
            
            if (response != nil && (response?.results().count)! > 0){
                let placemark :GMSAddress = response!.firstResult()
                
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
        var destinationPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        destinationPath += "/history_places.plist"
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: destinationPath) {
            print("File exists")
            if let histories = NSArray(contentsOfFile: destinationPath)
            {
                placeHistories.removeAllObjects()
                placeHistories.addObjects(from: histories as [AnyObject])
                self.dataTableView[1] = []
                for index in 0 ..< self.placeHistories.count-1{
                    self.dataTableView[1].insert((placeHistories[index] as! NSDictionary)["addressSugestion"]! as! String, at: index)
                }
            }
        }
    }
    
    func addressString(_ address:GMSAddress)-> String{
        var strSnippet : String = ""
        //MARK:: IBR-372 PO Wishes
        if (address.thoroughfare != nil) {
            strSnippet = TKPAddressStreet().getStreetAddress(address.thoroughfare)
        }
        strSnippet = adjustStrSnippet(address.administrativeArea, strSnippet: strSnippet)
        strSnippet = adjustStrSnippet(address.postalCode, strSnippet: strSnippet)
        
        if address.lines.count > 0 {
            strSnippet = address.lines.last as! String
        }
        return strSnippet
    }
    
    func adjustStrSnippet(_ address : String?, strSnippet: String) -> String
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
    
    func saveHistory (_ address :GMSAddress, addressSuggestions :GMSAutocompletePrediction?)
    {
        var documentsPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        documentsPath += "/history_places.plist"
        
        var addressString : String = ""
        
        if (address.thoroughfare != nil) {
            addressString = TKPAddressStreet().getStreetAddress(address.thoroughfare)
        }
        
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
        
        let history = [
            "addressSugestion"   :addressSugestionString,
            "address"            :addressString,
            "postal_code"        :postalCode,
            "place_id"           :placeID,
            "longitude"          :longitude,
            "latitude"           :latitude
        ] as [String : Any]
        let array : Array = dataTableView[1] as Array
        if(array.contains(history["addressSugestion"] as! String) == false)
        {
            placeHistories.insert(history, at: 0)
            placeHistories.write(toFile: documentsPath, atomically: true)
        }
    }
    
    func handleSearchForSearchString(_ searchString:String){
        let visibleRegion : GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds : GMSCoordinateBounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate:visibleRegion.nearRight)
        let filter : GMSAutocompleteFilter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
        
        placesClient?.autocompleteQuery(searchString, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
            if (error != nil){
                return
            }
            if(results!.count > 0){
                self.autoCompleteResults = results as! Array
                self.dataTableView[0]=[]
                for index in 0 ..< self.autoCompleteResults.count-1{
                    let place :GMSAutocompletePrediction = results![index] as! GMSAutocompletePrediction
                    self.dataTableView[0].insert(place.attributedFullText.string, at: index)
                }
                
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        })
    }
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataTableView.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTableView[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "reuseIdentifier")
        
        cell.textLabel!.font = UIFont.smallTheme();
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.setCustomAttributedText(dataTableView[indexPath.section][indexPath.row])
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleSection[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSearchBarActive(false, animated: true)
        
        if (indexPath.section == 0) {
            doGeneratePlaceDetail(autoCompleteResults[indexPath.row].placeID, addressSuggestion: autoCompleteResults[indexPath.row])
        } else {
            let coordinate : CLLocationCoordinate2D = CLLocationCoordinate2DMake((placeHistories[indexPath.row] as! NSDictionary)["latitude"]! as! CLLocationDegrees , (placeHistories[indexPath.row] as! NSDictionary)["longitude"]! as! CLLocationDegrees)
            mapView.updateCameraPosition(coordinate)
        }
        
        selectedSugestion = dataTableView[indexPath.section][indexPath.row]
        loadHistory()
    }

    //MARK: - Place Detail Request
    func doGeneratePlaceDetail(_ placeID:String, addressSuggestion:(GMSAutocompletePrediction))
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if((searchBar.text?.isEmpty) != nil){
            dataTableView[0].removeAll()
            tableView.reloadData()
        }
        handleSearchForSearchString(searchBar.text!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (searchBar.text == ""){
            dataTableView[0] = []
            tableView.reloadData()
        }

        setSearchBarActive(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setSearchBarActive(false, animated: true)
    }
    
    func setSearchBarActive(_ isActive:Bool, animated:Bool)
    {
        searchBar.setShowsCancelButton(isActive, animated: animated)
        self.navigationController?.setNavigationBarHidden(isActive, animated: animated)
        UIApplication.shared.setStatusBarHidden(isActive, with: UIStatusBarAnimation.slide)
        transparentView.isHidden = !isActive
        
        if (animated){
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
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
    
    func activeSearchBar(_ isActive: Bool)
    {
        searchBar.frame = CGRect(x: 0, y: 0, width: searchBar.frame.size.width, height: searchBar.frame.size.height)
        tableView.isHidden = !(isActive && (dataTableView[0].count>0 || dataTableView[1].count>0))
    }
    
}
