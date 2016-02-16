//
//  TPSpotlight.m
//  Tokopedia
//
//  Created by Tokopedia on 2/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "TPSpotlight.h"
#import <CoreSpotlight/CoreSpotlight.h>

// Objects
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishListObjectList.h"
#import "List.h"
#import "PromoProduct.h"
#import "TransactionCartList.h"
#import "ProductDetail.h"
#import "NavigateViewController.h"

#define TPActivityType @"com.tokopedia.Tokopedia"

@implementation TPSpotlight

typedef NS_ENUM(NSInteger, SearchIndexingStatus) {
    SearchIndexingDisable,
    SearchIndexingViewedRecords,
};

+ (SearchIndexingStatus)searchIndexingPreference {
    SearchIndexingStatus status = SearchIndexingDisable;
    status = [[NSUserDefaults standardUserDefaults] integerForKey:@"SearchIndexingPreference"];
    return status;
}

+ (NSUserActivity *)productDetailActivity:(id)product {
    // Product data
    NSDictionary *productFieldObjects = [product productFieldObjects];

    //Activity
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:TPActivityType];
    NSString *productTitle = productFieldObjects[@"name"];
    NSString *productPic = productFieldObjects[@"pic"];
    NSString *productURL = productFieldObjects[@"url"];
    NSString *productDeeplink = productFieldObjects[@"deeplink"];
    activity.title = productTitle;
    activity.userInfo = @{@"id" : productURL};
    activity.keywords = [NSSet setWithArray:@[productTitle]];
    activity.eligibleForPublicIndexing = YES;
    if ([TPSpotlight searchIndexingPreference] == SearchIndexingViewedRecords) {
        activity.eligibleForSearch = YES;
    } else {
        activity.eligibleForSearch = NO;
    }
    
    //Attribute set
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeData];
    attributeSet.title = productTitle;
    attributeSet.contentDescription = [productFieldObjects objectForKey:@"price_format"];
    attributeSet.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:productPic]];
    attributeSet.contentURL = [NSURL URLWithString:productURL];
    [activity becomeCurrent];
    
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:productDeeplink
                                                               domainIdentifier:@"product"
                                                                   attributeSet:attributeSet];

    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item]
                                                   completionHandler:^(NSError * _Nullable error) {
                                                       if (error) {
                                                           NSLog(@"Spotlight index error %@", error);
                                                       }
                                                   }];
    return activity;
}

@end
