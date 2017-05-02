//
//  GooglePlaceDetailLocation.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlaceDetailLocation : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

@end
