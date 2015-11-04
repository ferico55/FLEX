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


@interface PlacePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet MKMapView *mapMKView;

@property (nonatomic, weak) id<MKAnnotation> droppedAnnotation;

@end

@implementation PlacePickerViewController
{
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    
    NSMutableArray *_autoCompleteResults;
    
    BOOL shouldBeginEditing;
    BOOL _isDragging;
    
    GMSMarker *_marker;
    
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    
}

- (instancetype)init {
    if ((self = [super init])) {
//        CLLocationCoordinate2D southWestJakarta = CLLocationCoordinate2DMake(-6.2614927, 106.81059979999998);
//        CLLocationCoordinate2D northEastJakarta = CLLocationCoordinate2DMake(-6.211544, 106.845172);
//        GMSCoordinateBounds *JakartaBounds =
//        [[GMSCoordinateBounds alloc] initWithCoordinate:southWestJakarta coordinate:northEastJakarta];
//        GMSPlacePickerConfig *config =
//        [[GMSPlacePickerConfig alloc] initWithViewport:JakartaBounds];
//        _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        
        _placesClient = [[GMSPlacesClient alloc] init];
        _placesClient = [GMSPlacesClient sharedClient];
        _autoCompleteResults = [NSMutableArray new];
        shouldBeginEditing = YES;


    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    
    _mapview.myLocationEnabled = YES;
    _mapview.settings.myLocationButton = YES;
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            
        } else {
            NSLog(@"No place selected");
        }
    }];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
//    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapview.myLocationEnabled = YES;
    CLLocationManager *locationManager = [CLLocationManager new];
    [locationManager requestWhenInUseAuthorization];
//    self.view = _mapView;
    
    _marker = [[GMSMarker alloc] init];
    [_marker setDraggable:YES];
    _marker.position = locationManager.location.coordinate;
    _marker.map = _mapview;
    
    //[self.view insertSubview:_mapview atIndex:0];

    CLLocationCoordinate2D target = _marker.position;
    _mapview.camera = [GMSCameraPosition cameraWithTarget:target zoom:14];
    
    //[self focusMapToLocation:calgary];

    self.searchDisplayController.searchBar.placeholder = @"Cari Alamat";
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [_locationManager stopUpdatingLocation];
    
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             
             // strAdd -> take bydefault value nil
             NSString *strAdd = nil;
             
             if ([placemark.subThoroughfare length] != 0)
                 strAdd = placemark.subThoroughfare;
             
             if ([placemark.thoroughfare length] != 0)
             {
                 // strAdd -> store value of current location
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
                 else
                 {
                     // strAdd -> store only this value,which is not null
                     strAdd = placemark.thoroughfare;
                 }
             }
             
             if ([placemark.postalCode length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
                 else
                     strAdd = placemark.postalCode;
             }
             
             if ([placemark.locality length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                 else
                     strAdd = placemark.locality;
             }
             
             if ([placemark.administrativeArea length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                 else
                     strAdd = placemark.administrativeArea;
             }
             
             if ([placemark.country length] != 0)
             {
                 if ([strAdd length] != 0)
                     strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                 else
                     strAdd = placemark.country;
             }
             
             _marker.title = strAdd;
         }
     }];
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    _placesClient = [GMSPlacesClient sharedClient];

    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        [self focusMapToLocation:((GMSPlaceLikelihood*)likelihoodList.likelihoods[0]).place.coordinate];
    }];
    
    return YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y = point.y - 50;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];
    
    mapView.selectedMarker = marker;
    return YES;
}
- (IBAction)tapCurrentPosition:(id)sender {

}


- (void)focusMapToLocation:(CLLocationCoordinate2D)location
{
    _marker.position = location;
//    CLLocationCoordinate2D myLocation = _marker.position;
//    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];
//    bounds = [bounds includingCoordinate:_marker.position];
//    [_mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
    
//    CGPoint point = [_mapView.projection pointForCoordinate:_marker.position];
//    point.y = point.y - 100;
//    GMSCameraUpdate *camera =
//    [GMSCameraUpdate setTarget:[_mapView.projection coordinateForPoint:point]];
//    [_mapView animateWithCameraUpdate:camera];
//    _mapView.selectedMarker = _marker;
    
//    _mapView.camera = [GMSCameraPosition cameraWithTarget:location zoom:6];
//    GMSCameraUpdate *cam = [GMSCameraUpdate setTarget:location];
//    [_mapView animateWithCameraUpdate:cam];
    
//    CLLocationCoordinate2D current = location;
//    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:current];
//    [_mapView animateWithCameraUpdate:currentCam];
    
    CGPoint point = [_mapview.projection pointForCoordinate:_marker.position];
    point.y = point.y - 50;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[_mapview.projection coordinateForPoint:point]];
    [_mapview animateWithCameraUpdate:camera];
    
    GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                            longitude:location.longitude
                                                                 zoom:14];
    [_mapview setCamera:sydney];
    
    _mapview.selectedMarker = _marker;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_autoCompleteResults count];
}

- (GMSAutocompletePrediction *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [_autoCompleteResults objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self placeAtIndexPath:indexPath].attributedFullText.string;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self streetRowHeight:[self placeAtIndexPath:indexPath]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self doCalculateDistanceOrigin:@"Binus University - Syahdan Campus, Jalan Kh. Syahdan, Palmerah, Special Capital Region of Jakarta" withDestination:[self placeAtIndexPath:indexPath].attributedFullText.string];
    [self.searchDisplayController setActive:NO];
    [self doGeneratePlaceDetailPlaceID:[self placeAtIndexPath:indexPath].placeID];
//    [self doGeneratePlaceDetailAddress:[self placeAtIndexPath:indexPath].attributedFullText.string];
}

-(CGFloat)streetRowHeight:(GMSAutocompletePrediction*)place
{
    NSString *string = place.attributedFullText.string;
    
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(250,9999);
    CGSize expectedLabelSize = [string sizeWithFont:FONT_GOTHAM_BOOK_16
                                  constrainedToSize:maximumLabelSize
                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    if ([string isEqualToString:@""]) {
        expectedLabelSize.height = 0;
    }
    
    return 44+expectedLabelSize.height;
}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterGeocode;
    
    [_placesClient autocompleteQuery:searchString
                              bounds:nil
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker
{
    _isDragging = YES;
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker
{
    _isDragging = NO;
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (_isDragging) {
        
        return;
    }
    
    NSLog(@"Long press detected");
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"DroppedPin"];
    
    annotationView.draggable = YES;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    return annotationView;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 1.0;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)url
         inRange:(NSRange)characterRange {
    // Make links clickable.
    return YES;
}

#pragma mark - Place Detail
-(void)doGeneratePlaceDetailPlaceID:(NSString*)placeID
{
    [_placesClient lookUpPlaceID:placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (result != nil) {
            CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake(result.coordinate.latitude, result.coordinate.longitude);
            [self focusMapToLocation:c2D];
//            NSString *destination = [NSString stringWithFormat:@"%f,%f",result.coordinate.latitude, result.coordinate.longitude];
//            [self doCalculateDistanceOrigin:@"-6.193161,106.7892532" withDestination:destination];
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
