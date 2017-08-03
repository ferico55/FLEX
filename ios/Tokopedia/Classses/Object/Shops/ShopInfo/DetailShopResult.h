//
//  DetailShopResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ClosedInfo;
@class Owner;
@class Shipment;
@class Payment;
@class Address;
@class ShopInfo;
@class ShopStats;
@class ResponseSpeed;
@class Rating;
@class ShopTransactionStats;
#define CResponseSpeed @"respond_speed"
#define CRatings @"ratings"

typedef NS_ENUM(NSInteger, ShopActivity) {
    ShopActivityOpen,
    ShopActivityClosed,
    ShopActivityOther // inactive, in moderation
};

@interface DetailShopResult : NSObject

@property (nonatomic, strong) ClosedInfo *closed_info;
@property (nonatomic, strong) Owner     *owner;
@property (nonatomic, strong) NSArray *shipment;
@property (nonatomic, strong) NSArray *payment;
@property (nonatomic, strong) NSArray *address;
@property (nonatomic, strong) ShopInfo *info;
@property (nonatomic, strong) ShopStats *stats;
@property (nonatomic, strong) ResponseSpeed *respond_speed;
@property (nonatomic, strong) Rating *ratings;
@property (nonatomic, strong) ShopTransactionStats *shop_tx_stats;
@property (nonatomic, strong) NSNumber *is_open;
@property (nonatomic) ShopActivity activity;
@property (strong, nonatomic) NSString *useAce;
@property (nonatomic) BOOL isGetListProductFromAce;

+(RKObjectMapping*)mapping;

@end
