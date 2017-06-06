//
//  ShopProductPageResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
#import "ShopProductPageList.h"

@interface ShopProductPageResult : NSObject
@property(nonatomic, strong) Paging* paging;
@property(nonatomic, strong) NSArray<ShopProductPageList*>* list;

+(RKObjectMapping*)mapping;
@end
