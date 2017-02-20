//
//  FavoriteShopResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "ListFavoriteShop.h"

@interface FavoriteShopResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray<ListFavoriteShop*> *list;

+ (RKObjectMapping*) mapping;

@end
