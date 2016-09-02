//
//  ResolutionProductList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductTrouble;

@interface ResolutionProductList : NSObject
@property (strong, nonatomic) NSString* primary_photo;
@property (strong, nonatomic) NSString* order_dtl_id;
@property (strong, nonatomic) NSString* product_id;
@property (strong, nonatomic) NSString* show_input_quantity;
@property (strong, nonatomic) NSString* quantity;
@property (strong, nonatomic) NSString* primary_dtl_photo;
@property (strong, nonatomic) NSString* product_name;
@property (strong, nonatomic) NSString* snapshop_uri;
@property (strong, nonatomic) NSString* trouble_id;
@property (strong, nonatomic) NSString* trouble_name;
@property (strong, nonatomic) NSString* solution_remark;
@property (strong, nonatomic) NSString* is_free_return;

@property (strong, nonatomic) ProductTrouble *productTrouble;


+(RKObjectMapping*)mapping;
@end
