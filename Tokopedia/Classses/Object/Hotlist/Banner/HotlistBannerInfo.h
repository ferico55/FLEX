//
//  HotlistBannerInfo.h
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HotlistBannerQuery.h"

@interface HotlistBannerInfo : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *meta_description;
@property (nonatomic, strong) NSString *hotlist_description;
@property (nonatomic, strong) NSString *cover_img;
@property (nonatomic, strong) NSString *title;

@end
