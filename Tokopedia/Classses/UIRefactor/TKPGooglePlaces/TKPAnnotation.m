//
//  TKPAnnotation.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/3/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPAnnotation.h"

@implementation TKPAnnotation

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        // do whatever you want here ... I'm just grabbing the first placemark
        
        if ([placemarks count] > 0 && error == nil)
        {
            self.placemark = placemarks[0];
            
            NSArray *formattedAddressLines = self.placemark.addressDictionary[@"FormattedAddressLines"];
            self.title = [formattedAddressLines componentsJoinedByString:@", "];
        }
    }];
    
    _coordinate = coordinate;
}

@end
