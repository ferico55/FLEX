//
//  ImageSearchProduct.h
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModelView.h"

@interface ImageSearchProduct : NSObject

@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_gold_status;
@property (strong, nonatomic) NSString *shop_url;
@property (strong, nonatomic) NSString *is_owner;
@property (strong, nonatomic) NSString *rate;
@property (strong, nonatomic) NSString *product_id;
@property (strong, nonatomic) NSString *product_image_full;
@property (strong, nonatomic) NSString *product_talk_count;
@property (strong, nonatomic) NSString *product_image;
@property (strong, nonatomic) NSString *product_price;
@property (strong, nonatomic) NSString *product_sold_count;
@property (strong, nonatomic) NSString *shop_location;
@property (strong, nonatomic) NSString *product_wholesale;
@property (strong, nonatomic) NSString *shop_name;
@property (strong, nonatomic) NSString *product_review_count;
@property (strong, nonatomic) NSString *similarity_rank;
@property (strong, nonatomic) NSString *condition;
@property (strong, nonatomic) NSString *product_name;
@property (strong, nonatomic) NSString *product_url;

@property (nonatomic, strong) ProductModelView *viewModel;

@end
