//
//  ManageProduct.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManageProductResult.h"

@interface ManageProduct : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ManageProductResult *data;

+ (RKObjectMapping *)objectMapping;

@end
