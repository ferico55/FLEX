//
//  SearchAWSShop.h
//  Tokopedia
//
//  Created by Tonito Acen on 1/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchAWSShop : NSObject

@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_total_transaction;
@property (nonatomic, strong) NSString *shop_total_favorite;
@property (nonatomic, strong) NSString *shop_is_fave_shop;
@property (nonatomic, strong) NSString *shop_gold_shop;
@property (nonatomic, strong) NSString *shop_gold_status;


@end
