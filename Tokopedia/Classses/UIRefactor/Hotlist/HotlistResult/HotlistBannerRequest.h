//
//  HotlistBanner.h
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HotlistBannerResult;

@protocol HotlistBannerDelegate <NSObject>

@required
- (void)didReceiveBannerHotlist:(HotlistBannerResult*)bannerResult;

@end

@interface HotlistBannerRequest : NSObject <TokopediaNetworkManagerDelegate> {
    TokopediaNetworkManager *_bannerManager;
}

@property (weak, nonatomic) id<HotlistBannerDelegate> delegate;
@property (nonatomic) NSString *bannerKey;

- (void)requestBanner;

+(void)fetchHotlistBannerWithQuery:(NSString*)query
                         onSuccess:(void(^)(HotlistBannerResult* data))success
                         onFailure:(void(^)(NSError * error))failed;

@end
