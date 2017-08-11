//
//  SimpleFavoritedShopResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleFavoritedShopResult : NSObject
@property (strong, nonatomic) NSArray* shop_id_list;

+(RKObjectMapping*)mapping;
@end
