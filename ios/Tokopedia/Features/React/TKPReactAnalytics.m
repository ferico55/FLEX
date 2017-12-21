//
//  TKPReactAnalytics.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "TKPReactAnalytics.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>
#import "AnalyticsManager.h"
#import "Tokopedia-Swift.h"

@implementation TKPReactAnalytics


@synthesize bridge = _bridge;

- (id)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(trackScreenName:(NSString*)name) {
    [AnalyticsManager trackScreenName:name];
}

RCT_EXPORT_METHOD(trackEvent:(NSDictionary*)event) {
    [AnalyticsManager trackEventName:event[@"name"] category:event[@"category"] action:event[@"action"] label:event[@"label"]];
}

RCT_EXPORT_METHOD(moEngageEvent:(NSString *)name attributes:(NSDictionary *)attributes) {
    [AnalyticsManager moEngageTrackEventWithName:name attributes:attributes];
}

RCT_EXPORT_METHOD(trackPromoClickWithDictionary:(NSDictionary*)promotionsDict didSuccess:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    [AnalyticsManager trackPromoClickWithDictionary:promotionsDict];
}

RCT_EXPORT_METHOD(gtmTrack:(NSDictionary *)data) {
    [AnalyticsManager trackData:data];
}

RCT_EXPORT_METHOD(appsFlyerTrack:(NSDictionary *)data) {
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:data];
}

RCT_EXPORT_METHOD(branchTrack:(NSDictionary *)data) {
    NSMutableArray<BNCProduct*>* products = [NSMutableArray new];
    for(NSDictionary *pItem in data[@"products"]) {
        BNCProduct* product = [BNCProduct new];
        product.sku = pItem[@"id"];
        product.name = pItem[@"name"];
        product.price = pItem[@"price"];
        product.quantity = pItem[@"quantity"];
        [products addObject:product];
    }
    BNCCommerceEvent *commerceEvent = [BNCCommerceEvent new];
    commerceEvent.currency = data[@"currency"];
    commerceEvent.revenue = data[@"revenue"];
    commerceEvent.products = products;
    [[Branch getInstance] sendCommerceEvent:commerceEvent metadata:@{} withCompletion:^(NSDictionary *response, NSError *error) {
    }];
}

RCT_EXPORT_METHOD(moeTrack:(NSDictionary *)data) {
    [AnalyticsManager moEngageTrackEventWithName:data[@"name"]
                                      attributes:@{@"payment_type": data[@"payment_type"],
                                                   @"purchase_site": @"Marketplace",
                                                   @"total_price": data[@"total_price"]}];
}

@end
