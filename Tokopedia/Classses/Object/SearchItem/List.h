//
//  SearchItem.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface List : NSObject


/** catalog **/
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSString *catalog_name;
@property (nonatomic, strong) NSString *catalog_image;
@property (nonatomic, strong) NSString *catalog_price;

/** product **/
@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *shop_gold_status;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_name;

/** shop **/
@property (nonatomic, strong) NSString *shop_image;
//@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_total_transaction;
//@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_total_favorite;

@end
