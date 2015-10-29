//
//  BannerList.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKPObjectMapping.h"

@interface BannerTicker : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *img_uri;
@property (nonatomic, strong) NSString *url;

@end
