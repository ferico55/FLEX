//
//  FavoritedShopList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoritedShopList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;

+(NSDictionary *) attributeMappingDictionary;
+(RKObjectMapping *) mapping;

@end
