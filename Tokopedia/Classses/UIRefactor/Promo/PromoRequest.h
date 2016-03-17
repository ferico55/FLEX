//
//  PromoRequest.h
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoResponse.h"

#define PromoProductId       @"product_id"
#define PromoRefKey   @"ad_ref_key"
#define PromoClickURL @"ad_click_url"

typedef NS_ENUM(NSInteger, PromoRequestSourceType) {
    PromoRequestSourceSearch,
    PromoRequestSourceCategory,
    PromoRequestSourceHotlist,
    PromoRequestSourceFavoriteProduct,
    PromoRequestSourceFavoriteShop,
};

@protocol PromoRequestDelegate <NSObject>

- (void)didReceivePromo:(NSArray *)promo;

@optional;
- (void)didFinishedAddImpression;

@end

@interface PromoRequest : NSObject

@property NSInteger page;
@property (weak, nonatomic) id<PromoRequestDelegate> delegate;

- (void)requestForProductQuery:(NSString *)query
                    department:(NSString *)department;
- (void)requestForProductHotlist:(NSString *)key;
- (void)requestForProductFeed;
- (void)addImpressionKey:(NSString *)key
                  semKey:(NSString *)semKey
             referralKey:(NSString *)referralKey
                  source:(PromoRequestSourceType)source;

- (void)requestForProductFeed:(void (^)(NSArray<PromoResult*> *))successCallback
                    onFailure:(void (^)(NSError *))errorCallback;

- (void)requestForProductQuery:(NSString *)query
                    department:(NSString *)department
                     onSuccess:(void (^)(NSArray<PromoResult*> *))successCallback
                     onFailure:(void (^)(NSError *))errorCallback;


- (void)requestForClickURL:(NSString *)clickURL
                 onSuccess:(void (^)(void))successCallback
                 onFailure:(void (^)(NSError *))errorCallback;


@end