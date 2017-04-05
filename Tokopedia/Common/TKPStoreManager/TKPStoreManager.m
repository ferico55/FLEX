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
#import "TKPGooglePlaceDetailProductStore.h"

@implementation TKPStoreManager

@synthesize homeProductStore = _homeProductStore;
@synthesize homeBannerStore = _homeBannerStore;
@synthesize placeDetailStore = _placeDetailStore;
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

- (TKPGooglePlaceDetailProductStore *)placeDetailStore {
    if (_placeDetailStore == nil) {
        _placeDetailStore = [[TKPGooglePlaceDetailProductStore alloc] initWithStoreManager:self];
    }
    return _placeDetailStore;
}


- (NSOperationQueue *)networkQueue {
    if (_networkQueue == nil) {
        _networkQueue = [[NSOperationQueue alloc] init];
        [_networkQueue setMaxConcurrentOperationCount:5];
    }
    return _networkQueue;
}

@end
