//
//  ShopProductPageResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopProductPageResult.h"

@interface ShopProductPageResponse : NSObject
@property(nonatomic, strong) NSString* status;
@property(nonatomic, strong) NSArray* data;

+ (RKObjectMapping *)mapping;
@end
