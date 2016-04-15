//
//  RateAttributes.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateProduct.h"

@interface RateAttributes : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shipper_id;
@property (nonatomic, strong) NSString *shipper_name;
@property (nonatomic, strong) NSString *origin_id;
@property (nonatomic, strong) NSString *origin_name;
@property (nonatomic, strong) NSString *destination_id;
@property (nonatomic, strong) NSString *destination_name;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSString *auto_resi_image;

@end
