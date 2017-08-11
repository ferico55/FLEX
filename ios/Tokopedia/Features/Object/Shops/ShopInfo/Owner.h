//
//  Owner.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReputationDetail;
@interface Owner : NSObject

@property (nonatomic, strong) NSString *owner_image;
@property (nonatomic, strong) NSString *owner_phone;
@property (nonatomic) NSInteger owner_id;
@property (nonatomic, strong) NSString *owner_email;
@property (nonatomic, strong) NSString *owner_name;
@property (nonatomic, strong) NSString *owner_messenger;
@property (nonatomic, strong) ReputationDetail *owner_reputation;

+(RKObjectMapping*)mapping;
@end
