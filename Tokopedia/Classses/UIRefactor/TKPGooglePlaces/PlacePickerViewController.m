//
//  PlacePickerViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "PlacePickerViewController.h"
#import "TKPGooglePlaceDetailProductStore.h"
#import "GooglePlacesDetail.h"
#import "TKPAnnotation.h"

@import GoogleMaps;


@interface PlacePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapview;

@end

@implementation PlacePickerViewController
{
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    
    NSMutableArray *_autoCompleteResults;
    
    NSMutableArray *_placeHistories;
    
    BOOL shouldBeginEditing;
    BOOL _isDragging;
    __block BOOL _shouldStartSearch;
    
    GMSMarker *_marker;
    
    CLLocationManager *_locationManager;
    GMSGeocoder *_geocoder;
    
}

- (instancetype)init {
    if ((self = [super init])) {
        _placesClient = [[GMSPlacesClient alloc] init];
        _placesClient = [GMSPlacesClient sharedClient];
        _autoCompleteResults = [NSMutableArray new];
        shouldBeginEditing = YES;
        _shouldStartSearch = YES;
        self.title = @"Pilih Lokasi";

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [GMSGeocoder geocoder];
    
    _mapview.myLocationEnabled = YES;
    _mapview.settings.myLocationButton = YES;

    _mapview.myLocationEnabled = YES;
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] )
        [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    
    if (_firstCoordinate.longitude == 0) {
        _firstCoordinate = _locationManager.location.coordinate;
    }
    
    _marker = [[GMSMarker alloc] init];
    [_marker setDraggable:YES];
    _marker.position = _firstCoordinate;
    _marker.map = _mapview;
    _marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    
    //[self.view insertSubview:_mapview atIndex:0];

    CLLocationCoordinate2D target = _marker.position;
    _mapview.camera = [GMSCameraPosition cameraWithTarget:target zoom:14];
    
    //[self focusMapToLocation:calgary];

    self.searchDisplayController.searchBar.placeholder = @"Cari Alamat";
    self.searchDisplayController.searchBar.tintColor = [UIColor whiteColor];
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    [self updateAddressSaveHistory:NO addressSugestion:nil];
    _mapview.selectedMarker = _marker;
    
    _placeHistories = [NSMutableArray new];
    [self loadHistory];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{

}

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
////    InfoWindow *view =  [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
////    view.name.text = @"Place Name";
////    view.description.text = @"Place description";
////    view.phone.text = @"123 456 789";
////    view.placeImage.image = [UIImage imageNamed:@"customPlaceImage"];
////    view.placeImage.transform = CGAffineTransformMakeRotation(-.08);
////    return view;
//    
//    UIView *view = [[UIView alloc] init];
//    view.frame = CGRectMake(0, -100, 280, 40);
//    view.backgroundColor = [UIColor colorWithRed:0.5 green:0.8 blue:0.4 alpha:1.0];
//    
//    return view;
//}

-(void)updateAddressSaveHistory:(BOOL)shouldSaveHistory addressSugestion:(GMSAutocompletePrediction *)addressSugestion
{
    [_geocoder reverseGeocodeCoordinate:_marker.position completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
             // strAdd -> take bydefault value nil
        GMSAddress *placemark = [response results][0];
        
        _marker.snippet = [self addressString:placemark];
        
        [_mapview setSelectedMarker:_marker];
        
        if (shouldSaveHistory) {
            [self saveHistory:placemark addressSugestion:addressSugestion];
        }
    }];
}

-(NSString *)addressString:(GMSAddress*)address
{
    NSString *strSnippet = @"";
    
    if (address.lines.count>0) {
        strSnippet = address.lines[0];
    }
    else
    {
        if ([address.thoroughfare length] != 0)
        {
            // strAdd -> store value of current location
            if ([strSnippet length] != 0)
                strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address thoroughfare]];
            else
            {
                // strAdd -> store only this value,which is not null
                strSnippet = address.thoroughfare;
            }
        }
    }

    
    if ([address.locality length] != 0)
    {
        if ([strSnippet length] != 0)
            strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address locality]];
        else
            strSnippet = address.locality;
    }
    
    if ([address.subLocality length] != 0)
    {
        
        if ([strSnippet length] != 0)
            strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address subLocality]];
        else
        {
            // strAdd -> store only this value,which is not null
            strSnippet = address.subLocality;
        }
    }
    
    if ([address.administrativeArea length] != 0)
    {
        if ([strSnippet length] != 0)
            strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address administrativeArea]];
        else
            strSnippet = address.administrativeArea;
    }
    
    if ([address.country length] != 0)
    {
        if ([strSnippet length] != 0)
            strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address country]];
        else
            strSnippet = address.country;
    }
    
    if ([address.postalCode length] != 0)
    {
        if ([strSnippet length] != 0)
            strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[address postalCode]];
        else
            strSnippet = address.postalCode;
    }
    
    return strSnippet;
}

// Delegate method
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [_locationManager stopUpdatingLocation];
    
    
    [self focusMapToLocation:currentLocation.coordinate shouldUpdateAddress:YES shouldSaveHistory:NO addressSugestion:nil];
}


- (void)focusMapToLocation:(CLLocationCoordinate2D)location shouldUpdateAddress:(BOOL)shouldUpdateAddress shouldSaveHistory:(BOOL)saveHistory addressSugestion:(GMSAutocompletePrediction*)addressSugestion
{
    _marker.position = location;
    CGPoint point = [_mapview.projection pointForCoordinate:_marker.position];
    point.y = point.y - 50;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[_mapview.projection coordinateForPoint:point]];
    [_mapview animateWithCameraUpdate:camera];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                            longitude:location.longitude
                                                                 zoom:14];
    [_mapview setCamera:cameraPosition];
    _mapview.selectedMarker = _marker;
    
    if (shouldUpdateAddress)
        [self updateAddressSaveHistory:saveHistory addressSugestion:addressSugestion];
}

#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_placeHistories.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [_autoCompleteResults count];
    else
        return [_placeHistories count];
}

- (GMSAutocompletePrediction *)placeAtIndexPath:(NSIndexPath *)indexPath {
    if (_autoCompleteResults.count>0) {
        return [_autoCompleteResults objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSNumber *)placeLongitudeHistoryAtIndexPath:(NSIndexPath *)indexPath {
    if (_placeHistories.count > indexPath.row)
        return [_placeHistories objectAtIndex:indexPath.row][@"longitude"];
    return @(0);
}

- (NSNumber *)placeLatitudeHistoryAtIndexPath:(NSIndexPath *)indexPath {
    if (_placeHistories.count > indexPath.row)
        return [_placeHistories objectAtIndex:indexPath.row][@"latitude"];
    return @(0);
}

- (NSString *)placeSugestionHistoryAtIndexPath:(NSIndexPath *)indexPath {
    if (_placeHistories.count > indexPath.row)
        return [_placeHistories objectAtIndex:indexPath.row][@"addressSugestion"];
    return @"";
}

#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = FONT_GOTHAM_BOOK_13;
    if (indexPath.section == 0)
        [cell.textLabel setCustomAttributedText:[self placeAtIndexPath:indexPath].attributedFullText.string];
    else
        [cell.textLabel setCustomAttributedText:[self placeSugestionHistoryAtIndexPath:indexPath]];

    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Sugestions";
    }
    if (section == 1) {
        return @"Recent Searches";
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self streetRowHeight:[self placeAtIndexPath:indexPath]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO];
    
    if (indexPath.section == 0) {
        [self doGeneratePlaceDetailPlaceID:[self placeAtIndexPath:indexPath].placeID addressSugestion:[self placeAtIndexPath:indexPath]];
    }
    else
    {
        CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake([[self placeLatitudeHistoryAtIndexPath:indexPath] doubleValue], [[self placeLongitudeHistoryAtIndexPath:indexPath] doubleValue]);

        [self focusMapToLocation:annotationCoordinate
             shouldUpdateAddress:NO
               shouldSaveHistory:NO
                addressSugestion:[self placeAtIndexPath:indexPath]];
    }
}

-(CGFloat)streetRowHeight:(GMSAutocompletePrediction*)place
{
    NSString *string = place.attributedFullText.string;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(250,9999);
    CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_14
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    if ([string isEqualToString:@""]) {
        expectedLabelSize.height = 0;
    }
    
    return 44+expectedLabelSize.height;
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    
    if (_shouldStartSearch == NO) {
        return;
    }
    
    _shouldStartSearch = NO;
    
    GMSVisibleRegion visibleRegion = self.mapview.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                       coordinate:visibleRegion.nearRight];

    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    
    [_placesClient autocompleteQuery:searchString
                              bounds:bounds
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                _shouldStartSearch = YES;
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                [_autoCompleteResults removeAllObjects];
                                [_autoCompleteResults addObjectsFromArray:results];
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                }
                                [self.searchDisplayController.searchResultsTableView reloadData];
                            }];
}



#pragma mark - GMSMapView Delegate
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{
    _isDragging = YES;
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    _isDragging = NO;
    [self updateAddressSaveHistory:NO addressSugestion:nil];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (_isDragging) {
        
        return;
    }
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    [self focusMapToLocation:_locationManager.location.coordinate shouldUpdateAddress:YES shouldSaveHistory:NO addressSugestion:nil];
    
    return YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self focusMapToLocation:marker.position shouldUpdateAddress:NO shouldSaveHistory:NO addressSugestion:[GMSAutocompletePrediction new]];
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsZero;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - History Search
-(void)saveHistory:(GMSAddress*)address addressSugestion:(GMSAutocompletePrediction*)addressSugestion {
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"history_places.plist"];
    
    NSNumber *latitude = [NSNumber numberWithDouble:address.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:address.coordinate.longitude];

    
    NSDictionary *history = @{@"addressSugestion":addressSugestion.attributedFullText.string,
                              @"placeID":addressSugestion.placeID,
                              @"longitude": latitude,
                              @"latitude": longitude};
    
    if(![_placeHistories containsObject:history]) {
        [_placeHistories insertObject:history atIndex:0];
        [_placeHistories writeToFile:destPath atomically:YES];
    }
    
}

-(void)loadHistory {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"history_places.plist"];
    
    [_placeHistories addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:destPath]];
}

#pragma mark - Place Detail
-(void)doGeneratePlaceDetailPlaceID:(NSString*)placeID addressSugestion:(GMSAutocompletePrediction *)addressSugestion
{
    [_placesClient lookUpPlaceID:placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (result != nil) {
            CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake(result.coordinate.latitude, result.coordinate.longitude);
            [self focusMapToLocation:c2D shouldUpdateAddress:YES shouldSaveHistory:YES addressSugestion:addressSugestion];
        } else {
            NSLog(@"No place details for %@", placeID);
        }
    }];
}

-(void)doGeneratePlaceDetailAddress:(NSString*)address
{
    TKPGooglePlaceDetailProductStore *store = [[[[self class] TKP_rootController] storeManager] placeDetailStore];
    __weak typeof(self) wself = self;
    
    [store fetchGeocodeAddress:address success:^(NSString *address, GooglePlacesDetail *placeDetail) {
        NSString *destination = [NSString stringWithFormat:@"%@,%@",placeDetail.result.geometry.location.lat, placeDetail.result.geometry.location.lng];
        [self doCalculateDistanceOrigin:@"-6.193161,106.7892532" withDestination:destination];
    } failure:^(NSString *address, NSError *error) {
        
    }];
    
}



-(void)doCalculateDistanceOrigin:(NSString*)origin withDestination:(NSString*)destination
{
    TKPGooglePlaceDetailProductStore *store = [[[[self class] TKP_rootController] storeManager] placeDetailStore];
    __weak typeof(self) wself = self;
    
    [store fetchDistanceFromOrigin:origin toDestination:destination success:^(NSString *origin, NSString *destination, GoogleDistanceMatrix *dinstanceMatrix) {
        //((GoogleDistanceMatrixElement*)((GoogleDistanceMatrixRow*)placeDistance.rows[0]).elements[0]).distance.text
    } failure:^(NSString *origin, NSString *destination, NSError *error) {
        
    }];
}

@end
