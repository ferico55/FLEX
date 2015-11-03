//
//  PlacePickerViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "PlacePickerViewController.h"
#import "TKPGooglePlaceDetailProductStore.h"
#import "GooglePlacesDetail.h"

@import GoogleMaps;


@interface PlacePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, GMSMapViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapview;
@property (weak, nonatomic) IBOutlet MKMapView *mapMKView;

@end

@implementation PlacePickerViewController
{
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    
    NSMutableArray *_autoCompleteResults;
    
    BOOL shouldBeginEditing;
    
    GMSMapView *_mapView;
    GMSMarker *_marker;
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
        _autoCompleteResults = [NSMutableArray new];
        shouldBeginEditing = YES;
        
        
    }
    return self;
}
//#define METERS_PER_MILE 1609.344

//- (void)viewWillAppear:(BOOL)animated {
//    // 1
//    CLLocationCoordinate2D zoomLocation;
//    zoomLocation.latitude = 39.281516;
//    zoomLocation.longitude= -76.580806;
//    
//    // 2
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
//    
//    // 3
//    [_mapMKView setRegion:viewRegion animated:YES];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
//    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
//    self.view = _mapView;
    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) camera:camera];
    [self.view insertSubview:_mapView atIndex:0];

    CLLocationCoordinate2D vancouver = CLLocationCoordinate2DMake(-6.1823102, 106.8135506);
    CLLocationCoordinate2D calgary = CLLocationCoordinate2DMake(-6.211544, 106.845172);
    
    GMSMarker *vancouverMarker = [[GMSMarker alloc] init];
    vancouverMarker.position = vancouver;
    vancouverMarker.title = @"Vancouver";
    vancouverMarker.map = _mapview;
    
    GMSMarker *calgaryMarker = [[GMSMarker alloc] init];
    calgaryMarker.position = calgary;
    calgaryMarker.title = @"Calgary";
    calgaryMarker.map = _mapview;
    
    GMSCoordinateBounds *bounds =
    [[GMSCoordinateBounds alloc] initWithCoordinate:vancouver coordinate:calgary];
    
    [_mapview moveCamera:[GMSCameraUpdate fitBounds:bounds]];
//    These last two lines are expected to give the same result as the above line
//    camera = [mapView_ cameraForBounds:bounds insets:UIEdgeInsetsZero];
//    mapView_.camera = camera;
    
    self.searchDisplayController.searchBar.placeholder = @"Cari Alamat";
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)focusMapToLocation:(CLLocationCoordinate2D)location
{
    _marker.position = location;
    CLLocationCoordinate2D myLocation = _marker.position;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation coordinate:myLocation];
    bounds = [bounds includingCoordinate:_marker.position];
    
    [_mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
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
