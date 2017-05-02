//
//  SimpleFavoritedShop.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleFavoritedShopResult.h"

@interface SimpleFavoritedShop : NSObject
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) SimpleFavoritedShopResult *data;

+(RKObjectMapping*)mapping;
@end
