//
//  TKPStoreManager.h
//  Tokopedia
//
//  Created by Harshad Dange on 18/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKPHomeProductsStore;
@class TKPHomeBannerStore;

@class TKPGooglePlaceDetailProductStore;

@interface TKPStoreManager : NSObject

@property (strong, nonatomic, readonly) TKPHomeProductsStore *homeProductStore;
@property (strong, nonatomic, readonly) TKPHomeBannerStore *homeBannerStore;

@property (strong, nonatomic, readonly) TKPGooglePlaceDetailProductStore *placeDetailStore;

@property (strong, nonatomic, readonly) NSOperationQueue *networkQueue;


@end
