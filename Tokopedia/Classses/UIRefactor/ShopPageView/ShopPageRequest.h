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
#import "Talk.h"
#import "Review.h"
#import "Shop.h"
#import "Tokopedia-Swift.h"

@interface ShopPageRequest : NSObject

-(void)requestForShopPageContainerWithShopId:(NSString*)shopId
                                  shopDomain:(NSString*)shopDomain
                                   onSuccess:(void (^)(Shop*))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback;

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
                                     onSuccess:(void (^)(Talk*))successCallback
                                     onFailure:(void (^)(NSError *))errorCallback;

-(void)requestForShopReviewPageListingWithShopId:(NSString*)shopId
                                          page:(NSInteger)page
                                   shop_domain:(NSString*)shopDomain
                                     onSuccess:(void (^)(Review*))successCallback
                                     onFailure:(void (^)(NSError *))errorCallback;

-(void)requestForShopNotesPageListingWithShopId:(NSString*)shopId
                                   shop_domain:(NSString*)shopDomain
                                     onSuccess:(void (^)(NotesSwift*))successCallback
                                     onFailure:(void (^)(NSError *))errorCallback;



-(NSString*)splitUriToPage:(NSString*)uri;
@end
