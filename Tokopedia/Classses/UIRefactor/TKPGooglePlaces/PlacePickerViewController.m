//
//  PlacePickerViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "PlacePickerViewController.h"

@interface PlacePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@end

@implementation PlacePickerViewController
{
    GMSPlacePicker *_placePicker;
    GMSPlacesClient *_placesClient;
    
    NSMutableArray *_autoCompleteResults;
    
    BOOL shouldBeginEditing;
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
            
//            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
//                                                                    longitude:place.coordinate.longitude
//                                                                         zoom:6];
//            GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//            
//            GMSMarker *marker = [[GMSMarker alloc] init];
//            marker.position = camera.target;
//            marker.snippet = place.name;
//            marker.appearAnimation = kGMSMarkerAnimationPop;
//            marker.map = mapView;
//            
//            self.view = mapView;
            
        } else {
            NSLog(@"No place selected");
        }
    }];
    
    self.searchDisplayController.searchBar.placeholder = @"Search or Address";
    self.searchDisplayController.searchBar.barTintColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    
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

@end
