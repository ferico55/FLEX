//
//  Product.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DetailProductResult.h"

@interface Product : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;

@property BOOL isDummyProduct;

@property (nonatomic, strong) DetailProductResult *data;

+ (RKObjectMapping*)mapping;

@end
