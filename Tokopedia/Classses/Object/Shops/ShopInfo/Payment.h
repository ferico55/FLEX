//
//  Payment.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject

@property (nonatomic, strong) NSString *payment_image;
@property (nonatomic, strong) NSString *payment_id;
@property (nonatomic, strong) NSString *payment_name;
@property (nonatomic, strong) NSString *payment_info;
@property (nonatomic, strong) NSString *payment_default_status;

+(RKObjectMapping*)mapping;
@end
