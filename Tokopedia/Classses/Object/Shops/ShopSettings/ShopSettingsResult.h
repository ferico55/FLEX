//
//  ShopSettingsResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopSettingsResult : NSObject

@property (nonatomic) NSInteger is_success;
@property (nonatomic, strong) NSString *etalase_id;

+ (RKObjectMapping *)objectMapping;

@end
