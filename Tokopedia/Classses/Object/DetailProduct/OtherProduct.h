//
//  OtherProduct.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherProduct : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *product_price;
@property (nonatomic) NSNumber *product_id;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_name;

@end
