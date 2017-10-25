//
//  ReactTopAdsManager.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactTopAdsManager.h"
#import "Tokopedia-Swift.h"
#import "AnalyticsManager.h"

@implementation ReactTopAdsManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(sendClickImpressionWithClickUrlString:(NSString*)clickUrlString didSuccess:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    [TopAdsService sendClickImpressionWithClickURLString:clickUrlString];
}

RCT_EXPORT_METHOD(showTopAdsInfoActionSheet) {
    TopAdsInfoActionSheet *topAdsInfoActionSheet = [TopAdsInfoActionSheet new];
    [topAdsInfoActionSheet show];
}

@end
