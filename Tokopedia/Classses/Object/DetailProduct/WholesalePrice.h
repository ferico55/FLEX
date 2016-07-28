//
//  WholesalePrice.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WholesalePrice : NSObject

@property (strong, nonatomic) NSString *wholesale_min;
@property (strong, nonatomic) NSString *wholesale_max;
@property (strong, nonatomic) NSString *wholesale_price;

+(RKObjectMapping*)mappingForPromo;
+(RKObjectMapping*)mapping;

@end
