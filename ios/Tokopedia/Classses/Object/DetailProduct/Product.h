//
//  Product.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DetailProductResult.h"

@interface Product : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray <NSString*> *message_error;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;

@property BOOL isDummyProduct;

@property (nonatomic, strong, nonnull) DetailProductResult *data;


@end
