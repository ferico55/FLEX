//
//  ResolutionProductList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionProductList : NSObject
@property (strong, nonatomic) NSString* primary_photo;
@property (strong, nonatomic) NSString* order_dtl_id;
@property (strong, nonatomic) NSString* product_id;
@property (strong, nonatomic) NSString* show_input_quantity;
@property (strong, nonatomic) NSString* quantity;
@property (strong, nonatomic) NSString* primary_dtl_photo;
@property (strong, nonatomic) NSString* product_name;

+(RKObjectMapping*)mapping;
@end
