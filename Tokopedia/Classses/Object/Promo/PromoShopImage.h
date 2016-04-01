//
//  PromoShopImage.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PromoShopImage : NSObject
@property(strong, nonatomic) NSString* cover;
@property(strong, nonatomic) NSString* s_url;
@property(strong, nonatomic) NSString* xs_url;

+ (RKObjectMapping*)mapping;

@end
