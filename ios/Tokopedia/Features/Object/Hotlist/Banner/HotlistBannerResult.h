//
//  HotlistBannerResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HotlistBannerInfo.h"
#import "HotlistBannerQuery.h"

@class HotlistPromoInfo;

@interface HotlistBannerResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) HotlistBannerInfo *info;
@property (nonatomic, strong) HotlistBannerQuery *query;
@property (nonatomic) NSInteger disableTopAds;
@property (nonatomic, strong) HotlistPromoInfo *promoInfo;

@end
