//
//  AddShopResult.h
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddShopResult : NSObject

@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *status_domain;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_url;
@property (nonatomic, strong) NSString *post_key;

+ (RKObjectMapping *)mapping;

@end
