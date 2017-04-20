//
//  ManageProductList.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManageProductList : NSObject

@property (nonatomic) NSInteger product_count_review;
@property (nonatomic) NSInteger product_rating_point;
@property (nonatomic, strong) NSString *product_etalase;
@property (nonatomic) NSInteger product_count_talk;
@property (nonatomic) NSInteger product_shop_id;
@property (nonatomic, strong) NSString *product_status;
@property (nonatomic) NSInteger product_id;
@property (nonatomic) NSInteger product_count_sold;
@property (nonatomic) NSInteger product_currency_id;
@property (nonatomic) NSInteger product_shop_owner;
@property (nonatomic, strong) NSString *product_currency;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_normal_price;
@property (nonatomic, strong) NSString *product_image_300;
@property (nonatomic, strong) NSString *product_department;
@property (nonatomic, strong) NSString *product_url;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *product_currency_symbol;
@property (nonatomic, strong) NSString *product_no_idr_price;
@property (nonatomic, strong) NSString *product_etalase_id;

@property (nonatomic) BOOL onProcessUploading;

+ (RKObjectMapping *)objectMapping;

@end
