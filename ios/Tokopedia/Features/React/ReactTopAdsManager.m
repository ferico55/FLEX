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

RCT_EXPORT_METHOD(sendClickImpressionWithClickUrlString:(NSString*)clickUrlString
                  didSuccess:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    [TopAdsService sendClickImpressionWithClickURLString:clickUrlString];
}

RCT_EXPORT_METHOD(showAddPromoTooltip) {
    TopAdsAddPromoTipsActionSheet *alertController = [TopAdsAddPromoTipsActionSheet new];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertController show];
    });
}

RCT_EXPORT_METHOD(showTopAdsInfoActionSheet) {
    TopAdsInfoActionSheet *topAdsInfoActionSheet = [TopAdsInfoActionSheet new];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topAdsInfoActionSheet show];
    });
}

RCT_EXPORT_METHOD(requestTopAdsHeadline:(NSString*)departmentId didSuccess:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    TopAdsService *topAdsService = [TopAdsService new];
    
    [topAdsService getTopAdsJSONWithTopAdsFilter:[TopAdsFilter getTopAdsHeadlineCategoryFilterWithDepartmentId:departmentId source: TopAdsSourceDirectory] onSuccess:^(NSDictionary<NSString *,id> *promoResults) {
        resolve(promoResults);
    } onFailure:^(NSError *error) {
        reject(@(error.code).stringValue, error.localizedDescription, error);
    }];
}

@end
