//
//  ReactCategoryResultManager.m
//  Tokopedia
//
//  Created by Billion Goenawan on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactCategoryResultManager.h"
#import "Tokopedia-Swift.h"

@implementation ReactCategoryResultManager

- (dispatch_queue_t)methodQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getNextPageCategoryResultTopAdsWithCategoryId:(NSString*)categoryId page:(nonnull NSNumber* )page params:(NSDictionary*)params didSuccess:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    TopAdsService *topAdsService = [TopAdsService new];
    TopAdsFilter *filter = [[TopAdsFilter alloc] init];
    filter.source = TopAdsSourceDirectory;
    filter.departementId = categoryId;
    filter.currentPage = [page integerValue];
    filter.userFilter = params;
    filter.searchKeyword = @"";
    
    [topAdsService getTopAdsJSONWithTopAdsFilter:filter onSuccess:^(NSDictionary<NSString *,id> *promoResults) {
        resolve(promoResults);
    } onFailure:^(NSError *error) {
        reject(@(error.code).stringValue, error.localizedDescription, error);
    }];
}

RCT_EXPORT_METHOD(getNextPageCategoryResultProductWithCategoryId:(NSString*)categoryId page:(nonnull NSNumber* )page params:(NSDictionary*)params didSuccess:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    
    ProductAndWishlistNetworkManager *productAndWishlistNetworkManager = [[ProductAndWishlistNetworkManager alloc]init];
    
    NSMutableDictionary *paramsWithUpdatedPage = [params mutableCopy];
    
    [paramsWithUpdatedPage setObject:page forKey:@"start"];
    
    [productAndWishlistNetworkManager requestSearchWithParams:paramsWithUpdatedPage andPath:@"/search/v2.5/product" withCompletionHandler:^(SearchProductWrapper *searchProductWrapperResult) {
        resolve([searchProductWrapperResult wrap]);
    } andErrorHandler:^(NSError *error) {
        reject(@(error.code).stringValue, error.localizedDescription, error);
    }];
}

RCT_EXPORT_METHOD(showTopAdsInfoActionSheet) {
    TopAdsInfoActionSheet *topAdsInfoActionSheet = [TopAdsInfoActionSheet new];
    [topAdsInfoActionSheet show];
}

RCT_EXPORT_METHOD(showLoginModal) {
    [AuthenticationService.shared ensureLoggedInFromViewController:[UIApplication topViewController:[UIApplication sharedApplication].keyWindow.rootViewController] onSuccess:^{
        
    }];
}

@end
