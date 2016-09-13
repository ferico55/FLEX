//
//  ResolutionCenterCreatePOSTProduct.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionCenterCreatePOSTProduct : NSObject
@property (strong, nonatomic) NSString* product_id;
@property (strong, nonatomic) NSString* trouble_id;
@property (strong, nonatomic) NSString* quantity;
@property (strong, nonatomic) NSString* order_dtl_id;
@property (strong, nonatomic) NSString* remark;
+(RKObjectMapping*)mapping;
@end
