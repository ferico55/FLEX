//
//  SettingLocationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Paging.h"

@interface SettingLocationResult : NSObject

@property (nonatomic, strong) NSString *shop_is_gold;
@property (nonatomic, strong) NSString *default_sort;
@property (nonatomic, strong) NSString *etalase_id;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSString *total_data;
@property (nonatomic, strong) NSString *is_product_manager;
@property (nonatomic, strong) NSString *is_tx_manager;
@property (nonatomic, strong) NSString *is_inbox_manager;
@property (nonatomic, strong) NSString *etalase_name;
@property (nonatomic, strong) NSArray *list;
@property (nonatomic) BOOL is_allow;

+ (RKObjectMapping *)objectMapping;

@end
