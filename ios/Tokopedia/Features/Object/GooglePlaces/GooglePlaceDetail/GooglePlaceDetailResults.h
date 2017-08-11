//
//  GooglePlaceDetailResults.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleplaceDetailResult.h"

@interface GooglePlaceDetailResults : NSObject <TKPObjectMapping>

@property (nonatomic, strong) GoogleplaceDetailResult *result;

@end
