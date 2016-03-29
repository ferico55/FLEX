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
-(void)requestForShopProductPageListingWithShopId:(NSString*)shopId
                                        etalaseId:(NSString*)etalaseId
                                          keyWord:(NSString*)keyWord
                                             page:(NSInteger)page
                                         order_by:(NSString*)orderBy
                                      shop_domain:(NSString*)shopDomain
                                        onSuccess:(void (^)(ShopProductPageResult*))successCallback
                                        onFailure:(void (^)(NSError *))errorCallback;

-(void)requestForShopTalkPageListingWithShopId:(NSString*)shopId
                                          page:(NSInteger)page
                                   shop_domain:(NSString*)shopDomain
                                     onSuccess:(void (^)(ShopProductPageResult*))successCallback
                                     onFailure:(void (^)(NSError *))errorCallback;

-(void)requestF

-(NSString*)splitUriToPage:(NSString*)uri;
@end
