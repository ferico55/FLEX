//
//  BannerResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKPObjectMapping.h"
#import "BannerList.h"
#import "BannerTicker.h"

@interface BannerResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *banner;
@property (nonatomic, strong) BannerTicker *ticker;

@end
