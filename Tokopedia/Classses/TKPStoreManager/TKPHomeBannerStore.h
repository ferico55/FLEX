//
//  TKPHomeBannerStore.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Banner;
@class TKPStoreManager;
@class Slide;
@class MiniSlide;

@interface TKPHomeBannerStore : NSObject

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager;

- (void)fetchBannerWithCompletion:(void (^) (NSArray<Slide*>* banner, NSError *error))completion;
- (void)fetchMiniSlideWithCompletion:(void (^) (NSArray<MiniSlide*>* banner, NSError *error))completion;

- (void)stopBannerRequest;

@property (weak, nonatomic) TKPStoreManager *storeManager;

@end
