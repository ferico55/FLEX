//
//  TKPAnnotation.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/3/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TKPAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate;

@end
