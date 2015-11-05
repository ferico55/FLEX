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
    GMSGeocoder *_geocoder;
    
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
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    [self updateMarkerLocationAddress];
    _mapview.selectedMarker = _marker;
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

-(void)updateMarkerLocationAddress
{
    [_geocoder reverseGeocodeCoordinate:_marker.position completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
             // strAdd -> take bydefault value nil
        NSString *strAdd = @"";
        NSString *strSnippet = @"";

        GMSAddress *placemark = [response results][0];

         if ([placemark.thoroughfare length] != 0)
         {
             // strAdd -> store value of current location
             if ([strSnippet length] != 0)
                 strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark thoroughfare]];
             else
             {
                 // strAdd -> store only this value,which is not null
                 strSnippet = placemark.thoroughfare;
             }
         }
        
        if ([placemark.locality length] != 0)
        {
            if ([strSnippet length] != 0)
                strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark locality]];
            else
                strSnippet = placemark.locality;
        }

         if ([placemark.subLocality length] != 0)
         {

             if ([strSnippet length] != 0)
                 strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark subLocality]];
             else
             {
                 // strAdd -> store only this value,which is not null
                 strSnippet = placemark.subLocality;
             }
         }

         if ([placemark.administrativeArea length] != 0)
         {
             if ([strSnippet length] != 0)
                 strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark administrativeArea]];
             else
                 strSnippet = placemark.administrativeArea;
         }

         if ([placemark.country length] != 0)
         {
             if ([strSnippet length] != 0)
                 strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark country]];
             else
                 strSnippet = placemark.country;
         }
         
         if ([placemark.postalCode length] != 0)
         {
             if ([strSnippet length] != 0)
                 strSnippet = [NSString stringWithFormat:@"%@, %@",strSnippet,[placemark postalCode]];
             else
                 strSnippet = placemark.postalCode;
         }
        
        _marker.snippet = strSnippet;
        
        [_mapview setSelectedMarker:_marker];
    }];

}

// Delegate method
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
        NSLog(@"longitude = %.8f\nlatitude = %.8f", currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    
    // stop updating location in order to save battery power
    [_locationManager stopUpdatingLocation];
    
    
    [self focusMapToLocation:currentLocation.coordinate];
}

-(BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView
{
    [self focusMapToLocation:_locationManager.location.coordinate];
    
    return YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self focusMapToLocation:marker.position];
    return YES;
}
- (IBAction)tapCurrentPosition:(id)sender {

}


- (void)focusMapToLocation:(CLLocationCoordinate2D)location
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
    [self updateMarkerLocationAddress];
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
    
    GMSVisibleRegion visibleRegion = self.mapview.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                       coordinate:visibleRegion.nearRight];

    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    
    [_placesClient autocompleteQuery:searchString
                              bounds:bounds
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
    [self updateMarkerLocationAddress];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (_isDragging) {
        
        return;
    }
    
    NSLog(@"Long press detected");
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
