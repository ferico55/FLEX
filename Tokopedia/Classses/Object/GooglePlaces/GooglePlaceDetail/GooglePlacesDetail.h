//
//  GooglePlacesDetail.h
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GoogleplaceDetailResult.h"
#import "GooglePlaceDetailResults.h"

@interface GooglePlacesDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) GoogleplaceDetailResult *result;
@property (nonatomic, strong) NSArray *results;

@end
