//
//  GooglePlaceDetailGeometry.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GooglePlaceDetailLocation.h"

@interface GooglePlaceDetailGeometry : NSObject <TKPObjectMapping>

@property (nonatomic, strong) GooglePlaceDetailLocation *location;

@end
