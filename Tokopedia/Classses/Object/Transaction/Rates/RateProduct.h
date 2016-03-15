//
//  RateProduct.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateProduct : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shipper_product_id;
@property (nonatomic, strong) NSString *shipper_product_name;
@property (nonatomic, strong) NSString *shipper_product_desc;
@property (nonatomic, strong) NSString *price;

@end
