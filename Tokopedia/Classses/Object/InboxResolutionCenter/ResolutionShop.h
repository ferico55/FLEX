//
//  ResolutionShop.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopReputation.h"

#define CShopReputation @"shop_reputation"

@interface ResolutionShop : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) ShopReputation *shop_reputation;

@end
