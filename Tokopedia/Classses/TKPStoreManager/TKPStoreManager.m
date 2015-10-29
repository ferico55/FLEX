//
//  TKPStoreManager.m
//  Tokopedia
//
//  Created by Harshad Dange on 18/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPStoreManager.h"
#import "TKPHomeProductsStore.h"
#import "TKPHomeBannerStore.h"

@implementation TKPStoreManager

@synthesize homeProductStore = _homeProductStore;
@synthesize homeBannerStore = _homeBannerStore;
@synthesize networkQueue = _networkQueue;

- (TKPHomeProductsStore *)homeProductStore {
    if (_homeProductStore == nil) {
        _homeProductStore = [[TKPHomeProductsStore alloc] initWithStoreManager:self];
    }
    return _homeProductStore;
}

- (TKPHomeBannerStore *)homeBannerStore {
    if (_homeBannerStore == nil) {
        _homeBannerStore = [[TKPHomeBannerStore alloc] initWithStoreManager:self];
    }
    return _homeBannerStore;
}


- (NSOperationQueue *)networkQueue {
    if (_networkQueue == nil) {
        _networkQueue = [[NSOperationQueue alloc] init];
        [_networkQueue setMaxConcurrentOperationCount:5];
    }
    return _networkQueue;
}

@end
