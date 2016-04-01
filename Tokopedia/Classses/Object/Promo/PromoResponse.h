//
//  PromoResponse.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoResult.h"

@interface PromoResponse : NSObject

@property (nonatomic, strong) NSArray* data;
+ (RKObjectMapping *)mapping;

@end
