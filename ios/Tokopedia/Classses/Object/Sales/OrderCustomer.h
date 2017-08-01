//
//  NewOrderCustomer.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderCustomer : NSObject

@property (strong, nonatomic) NSString *customer_url;
@property (strong, nonatomic) NSString *customer_id;
@property (strong, nonatomic) NSString *customer_name;
@property (strong, nonatomic) NSString *customer_image;

+ (RKObjectMapping *)mapping;

@end
