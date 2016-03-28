//
//  ShopPageRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopProductPageResponse.h"
#import "ShopProductPageResult.h"

@interface ShopPageRequest : NSObject
-(void)requestForShopProductPageListingWithShopId:(NSString *)shopId onSuccess:(void (^)(NSArray<ShopProductPageResult*>*))successCallback onFailure:(void (^)(NSError *))errorCallback;
@end
