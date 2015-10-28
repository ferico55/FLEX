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

@interface TKPHomeBannerStore : NSObject

- (instancetype)initWithStoreManager:(TKPStoreManager *)storeManager;

- (void)fetchBannerWithCompletion:(void (^) (Banner *banner, NSError *error))completion;

@property (weak, nonatomic) TKPStoreManager *storeManager;

@end
