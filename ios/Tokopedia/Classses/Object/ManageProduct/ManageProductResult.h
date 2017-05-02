//
//  ManageProductResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManageProductList.h"
#import "Paging.h"

@interface ManageProductResult : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSString *default_sort;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSNumber *total_data;
@property (nonatomic) BOOL is_product_manager;
@property (nonatomic) BOOL is_tx_manager;
@property (nonatomic) BOOL is_inbox_manager;
@property (nonatomic, strong) NSString *etalase_name;
@property (nonatomic, strong) NSString *menu_id;

+ (RKObjectMapping *)objectMapping;

@end
