//
//  HotlistBannerQuery.h
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotlistBannerQuery : NSObject <TKPObjectMapping>


@property (nonatomic, strong) NSString *negative_keyword;
@property (nonatomic, strong) NSString *sc;
@property (nonatomic, strong) NSString *ob;
@property (nonatomic, strong) NSString *terms;
@property (nonatomic, strong) NSString *fshop;
@property (nonatomic, strong) NSString *q;
@property (nonatomic, strong) NSString *pmin;
@property (nonatomic, strong) NSString *pmax;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *hot_id;

@end
