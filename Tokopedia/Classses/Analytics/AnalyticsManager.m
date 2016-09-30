//
//  AnalyticsManager.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AnalyticsManager.h"
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishlistObjectList.h"
#import "List.h"

@interface AnalyticsManager()

@property (strong, nonatomic) TAGDataLayer *dataLayer;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

@end

@implementation AnalyticsManager

- (id)init {
    self = [super init];
    if (self) {
        _dataLayer = [TAGManager instance].dataLayer;
        _userManager = [UserAuthentificationManager new];
        [_dataLayer push:@{@"user_id" : [_userManager getUserId]?:@""}];
    }
    
    return self;
}

// Localytics Tracking

+ (void)localyticsEvent:(NSString *)event {
    [Localytics tagEvent:event?:@""];
}

+ (void)localyticsEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    [Localytics tagEvent:event?:@""
              attributes:attributes];
}

// GA Tracking

+ (void)trackScreenName:(NSString *)name {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        NSDictionary *data = @{
                               @"event" : @"authenticated",
                               @"contactInfo" : @{
                                       @"userSeller": [[manager.userManager getShopId] isEqualToString:@"0"]? @"0": @"1",
                                       @"userFullName": [[manager.userManager getUserLoginData] objectForKey:@"full_name"]?:@"",
                                       @"userEmail": [[manager.userManager getUserLoginData] objectForKey:@"user_email"]?:@"",
                                       @"userId": [manager.userManager getUserId],
                                       @"userMSISNVerified": [[manager.userManager getUserLoginData] objectForKey:@"msisdn_is_verified"]?:@"",
                                       @"shopID": [manager.userManager getShopId]
                                       }
                               };
        
        [manager.dataLayer push:data];
    }
    
    [manager.dataLayer push:@{@"event" : @"openScreen",
                              @"screenName" : name?:@""}];
    
    [Localytics tagScreen:name];
}

+ (void)trackScreenName:(NSString *)name gridType:(NSInteger)gridType {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openScreen",
                           @"screenName" : name?:@"",
                           @"gridType" : @(gridType)
                           };
    
    [manager.dataLayer push:data];
    
    [Localytics tagScreen:name?:@""];
}

+ (void)trackUserInformation {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        [manager.dataLayer push:@{@"user_id" : [manager.userManager getUserId]?:@""}];
        
        [Localytics setValue:[manager.userManager getUserId]?:@"" forProfileAttribute:@"user_id"];
        [Localytics setValue:[manager.userManager getUserId]?:@"" forProfileAttribute:@"shop_id"];
    }
}

- (NSString *)getProductListName:(id)product {
    NSString *list = @"";
    if ([product isKindOfClass:[SearchAWSProduct class]]) {
        list = @"Search Results";
    } else if ([product isKindOfClass:[ProductFeedList class]]) {
        list = @"Product Feed";
    } else if ([product isKindOfClass:[WishListObjectList class]]) {
        list = @"Wish List";
    } else if ([product isKindOfClass:[List class]]) {
        list = @"Shop Product";
    }
    return list;
    
}

+ (void)trackProductImpressions:(NSArray *)products {
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *impressions = [NSMutableArray new];
    
    for (id product in products) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[product productFieldObjects]];
        NSString *listName = [manager getProductListName:product];
        [dict setObject:listName forKey:@"list"];
        [impressions addObject:dict];
    }
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"impressions" : impressions
                                   }
                           };
    
    [manager.dataLayer push:data];
}

// AppsFlyer Tracking



@end
