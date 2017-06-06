//
//  FavoritedShopResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Paging;
#import "FavoritedShopList.h"

@interface FavoritedShopResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSArray *list_gold;

+(RKObjectMapping *) mapping;

@end
