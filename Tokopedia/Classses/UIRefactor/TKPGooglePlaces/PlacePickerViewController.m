//
//  PlacePickerViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "PlacePickerViewController.h"
#import "TKPGooglePlaceDetailProductStore.h"
#import "GooglePlacesDetail.h"
#import "TKPAnnotation.h"

@import GoogleMaps;


@interface PlacePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, GMSMapViewDelegate, CLLocationManagerDelegate, UISearchControllerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet GMSMapView *transparentView;


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
    GMSAddress *_address;
    
    UIImage *_captureScreen;
    NSString *_selectedSugestion;
}

- (instancetype)init {
    if ((self = [super init])) {
        _placesClient = [[GMSPlacesClient alloc] init];
        _placesClient = [GMSPlacesClient sharedClient];
        _autoCompleteResults = [NSMutableArray new];
        shouldBeginEditing = YES;
        _shouldStartSearch = YES;

    }
    return self;
}
- (IBAction)cancelSearch:(id)sender {
    
    [self setSearchbarActive:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [GMSGeocoder geocoder];

    _mapview.myLocationEnabled = YES;
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] )
        [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    
    if (_firstCoordinate.longitude == 0) {
        _firstCoordinate = _locationManager.location.coordinate;
    }
    
    _marker = [[GMSMarker alloc] init];
    _marker.position = _firstCoordinate;
    _marker.map = _mapview;
    _marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
    
    CLLocationCoordinate2D target = _marker.position;
    _mapview.camera = [GMSCameraPosition cameraWithTarget:target zoom:14];
    
    _searchBar.placeholder = @"Cari Alamat";
    _searchBar.tintColor = [UIColor whiteColor];
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    _searchBar.delegate = self;
    
    [self updateAddressSaveHistory:NO addressSugestion:nil];
    _mapview.selectedMarker = _marker;
    
    _placeHistories = [NSMutableArray new];
    
    if (_type == TypeEditPlace) {
        UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapDone)];
        [doneBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = doneBarButtonItem;
        self.title = @"Pilih Lokasi";
        [_marker setDraggable:YES];

    }
    else
    {
        self.title = @"Lokasi";
        _searchBar.hidden = YES;
        
    }
    
    [self loadHistory];
    [self performSelector:@selector(setCaptureMap) withObject:nil afterDelay:1.0f];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied) {
        
    }
    else
    {
        if (_marker.position.latitude != 0 && _marker.position.longitude != 0)
            [self focusMapToLocation:_locationManager.location.coordinate shouldUpdateAddress:YES shouldSaveHistory:NO addressSugestion:nil];
        _mapview.myLocationEnabled = YES;
        _mapview.settings.myLocationButton = YES;
    }
}

-(void)tapDone
{
    [self mapView:_mapview didTapInfoWindowOfMarker:_marker];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    _selectedSugestion = @"";
    [self focusMapToLocation:coordinate shouldUpdateAddress:YES shouldSaveHistory:NO addressSugestion:nil];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    UIImage *map = _captureScreen?:[PlacePickerViewController captureScreen:mapView];
    _mapview.selectedMarker = nil;
    [_delegate PickAddress:_address suggestion:_selectedSugestion?:@"" longitude:marker.position.longitude latitude:marker.position.latitude map:map];
    
    [self.navigationController popViewControllerAnimated:YES];
}

+ (UIImage *)captureScreen:(GMSMapView *)mapView {
    
    UIGraphicsBeginImageContextWithOptions(mapView.frame.size, YES, 0.0f);
    [mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)setCaptureMap
{
    _captureScreen = [PlacePickerViewController captureScreen:_mapview];
}


- (void)setSearchbarActive:(BOOL)isActive animated:(BOOL)animated{
    [_searchBar setShowsCancelButton:isActive animated:animated];
    [self.navigationController setNavigationBarHidden:isActive animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:isActive withAnimation:UIStatusBarAnimationSlide];
    _transparentView.hidden = !isActive;
    
    if (isActive) {
        
        if (animated) {
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                [self activeSearhBar:isActive];
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            [self activeSearhBar:isActive];
        }

    }
    else
    {
        if (animated) {
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                [self activeSearhBar:isActive];
                [_searchBar resignFirstResponder];
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            [_searchBar resignFirstResponder];
            [self activeSearhBar:isActive];
        }
    }
}

-(void)activeSearhBar:(BOOL)isActive
{
    _searchBar.frame = (CGRect){.origin = {0, 0}, .size = _searchBar.frame.size};
    _tableView.hidden = !(isActive && _placeHistories.count > 0);
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
        _address = placemark;
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
    
    
    //[self focusMapToLocation:currentLocation.coordinate shouldUpdateAddress:YES shouldSaveHistory:NO addressSugestion:nil];
}


- (void)focusMapToLocation:(CLLocationCoordinate2D)location shouldUpdateAddress:(BOOL)shouldUpdateAddress shouldSaveHistory:(BOOL)saveHistory addressSugestion:(GMSAutocompletePrediction*)addressSugestion
{
    _marker.position = location;
    _mapview.selectedMarker = _marker;

    [PlacePickerViewController focusMap:_mapview toMarker:_marker];
    
    [self performSelector:@selector(setCaptureMap) withObject:nil afterDelay:1.0f];
    
    if (shouldUpdateAddress)
        [self updateAddressSaveHistory:saveHistory addressSugestion:addressSugestion];
}

+(void)focusMap:(GMSMapView*)mapView toMarker:(GMSMarker*)marker
{
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y = point.y - 50;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:marker.position.latitude
                                                                    longitude:marker.position.longitude
                                                                         zoom:14];
    [mapView setCamera:cameraPosition];
    
}

#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [_autoCompleteResults count];
    else
        return [_placeHistories count];
}

- (GMSAutocompletePrediction *)placeAtIndexPath:(NSIndexPath *)indexPath {
    if (_autoCompleteResults.count>0 && _autoCompleteResults.count>indexPath.row) {
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

- (NSString *)placeNameHistoryAtIndexPath:(NSIndexPath *)indexPath {
    if (_placeHistories.count > indexPath.row)
        return [_placeHistories objectAtIndex:indexPath.row][@"address"];
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
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;

    if (indexPath.section == 0)
    {
        [cell.textLabel setCustomAttributedText:[self placeAtIndexPath:indexPath].attributedFullText.string];
        UIFont *regularFont = FONT_GOTHAM_BOOK_13;
        UIFont *boldFont = FONT_GOTHAM_MEDIUM_13;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSMutableAttributedString *bolded = [[self placeAtIndexPath:indexPath].attributedFullText mutableCopy];
        [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                           inRange:NSMakeRange(0, bolded.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            UIFont *font = (value == nil) ? regularFont : boldFont;
                            [bolded addAttribute:NSFontAttributeName value:font range:range];
                        }];
        [bolded addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [bolded length])];

        
        cell.textLabel.attributedText = bolded;
    }
    else
        [cell.textLabel setCustomAttributedText:[self placeSugestionHistoryAtIndexPath:indexPath]];

    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _autoCompleteResults.count > 0) {
        return @"Suggestions";
    }
    if (section == 1 && _placeHistories.count > 0) {
        return @"Recent Searches";
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [self streetRowHeight:[self placeAtIndexPath:indexPath].attributedFullText.string];
    else
        return [self streetRowHeight:[self placeSugestionHistoryAtIndexPath:indexPath]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *searchbarText = _searchBar.text;
    [self setSearchbarActive:NO animated:YES];
    _searchBar.text = searchbarText;
    if ([searchbarText isEqualToString:@""]) {
        [_autoCompleteResults removeAllObjects];
        [_tableView reloadData];
    }
    
    if (indexPath.section == 0) {
        [self doGeneratePlaceDetailPlaceID:[self placeAtIndexPath:indexPath].placeID addressSugestion:[self placeAtIndexPath:indexPath]];
        _selectedSugestion = [self placeAtIndexPath:indexPath].attributedFullText.string;
    }
    else
    {
        CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake([[self placeLatitudeHistoryAtIndexPath:indexPath] doubleValue],[[self placeLongitudeHistoryAtIndexPath:indexPath] doubleValue]);

        [self focusMapToLocation:annotationCoordinate
             shouldUpdateAddress:NO
               shouldSaveHistory:NO
                addressSugestion:[self placeAtIndexPath:indexPath]];
        _marker.snippet = [self placeNameHistoryAtIndexPath:indexPath];
        _selectedSugestion = [self placeSugestionHistoryAtIndexPath:indexPath];
    }
}

-(CGFloat)streetRowHeight:(NSString*)place
{
    NSString *string = place;
    
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
                                _tableView.hidden = NO;
                                [_tableView reloadData];
                            }];
    

}



#pragma mark - GMSMapView Delegate
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{
    _selectedSugestion = @"";
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
    [self focusMapToLocation:marker.position shouldUpdateAddress:NO shouldSaveHistory:NO addressSugestion:nil];
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    controller.searchResultsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.f, 30.f, 0.f);
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) {
        [self handleSearchForSearchString:searchText];
    }
    else
    {
        [_autoCompleteResults removeAllObjects];
        [_tableView reloadData];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text  isEqualToString:@""]) {
        [_autoCompleteResults removeAllObjects];
        [_tableView reloadData];
    }
    
    [self setSearchbarActive:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setSearchbarActive:NO animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void)constraint
{
    UITableView *tableView = _tableView;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:tableView.superview
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView.superview
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView.superview
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView.superview
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
}

#pragma mark - History Search
-(void)saveHistory:(GMSAddress*)address addressSugestion:(GMSAutocompletePrediction*)addressSugestion {
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"history_places.plist"];
    
    NSNumber *latitude = [NSNumber numberWithDouble:address.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:address.coordinate.longitude];

    
    NSDictionary *history = @{@"addressSugestion"   :addressSugestion.attributedFullText.string,
                              @"address"            :(address.lines.count>0)?address.lines[0]:address.thoroughfare?:@"",
                              @"postal_code"        :address.postalCode?:@"",
                              @"locality"           :address.locality?:@"",
                              @"subLocality"        :address.subLocality?:@"",
                              @"administrativeArea" :address.administrativeArea?:@"",
                              @"country"            :address.country?:@"",
                              @"place_id"           :addressSugestion.placeID?:@"",
                              @"longitude"          :longitude?:@"",
                              @"latitude"           :latitude?:@""
                              };
    
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
