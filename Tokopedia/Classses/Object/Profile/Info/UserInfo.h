//
//  UserInfo.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReputationDetail.h"

#define CUserReputation @"user_reputation"

@interface UserInfo : NSObject

@property (nonatomic, strong) NSString *user_email;
@property (nonatomic, strong) NSString *user_messenger;
@property (nonatomic, strong) NSString *user_hobbies;
@property (nonatomic, strong) NSString *user_phone;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *user_birth;
@property (nonatomic, strong) ReputationDetail *user_reputation;

+ (RKObjectMapping *)mapping;

@end
