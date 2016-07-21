//
//  ProductRequest.h
//  Tokopedia
//
//  Created by Tokopedia on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EtalaseList.h"
#import "ShopSettings.h"
#import "HistoryProduct.h"

@interface ProductRequest : NSObject

+ (void)moveProductToWarehouse:(NSString *)productId
 setCompletionBlockWithSuccess:(void (^)(ShopSettings *response))success
                       failure:(void (^)(NSArray *errorMessages))failure;

+ (void)moveProduct:(NSString *)productId
          toEtalase:(EtalaseList *)etalase
setCompletionBlockWithSuccess:(void (^)(ShopSettings *response))success
            failure:(void (^)(NSArray *errorMessages))failure;

+ (void)deleteProductWithId:(NSString *)productId
setCompletionBlockWithSuccess:(void (^)(ShopSettings *response))success
                    failure:(void (^)(NSArray *errorMessages))failure;

+ (void)requestHistoryProductOnSuccess:(void (^)(HistoryProduct *productHistory))success
                             OnFailure:(void (^)(NSError *error))failure;

@end
