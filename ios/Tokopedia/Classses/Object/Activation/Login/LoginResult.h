//  LoginResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginSecurity.h"

@class ReputationDetail;

@interface LoginResult : NSObject //<NSCoding>

@property (nonatomic) BOOL is_login;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_avatar;
@property (nonatomic) NSInteger shop_is_gold;
@property (nonatomic) NSInteger shop_is_official;

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *shop_has_terms;
@property (nonatomic, strong) NSString *full_name;
@property (nonatomic, strong) NSString *user_image;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *msisdn_is_verified;
@property (nonatomic, strong) NSString *msisdn_show_dialog;

//even though the web service don’t return email, I think it makes sense to group email to this data
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) LoginSecurity* security;


@property (nonatomic, strong) ReputationDetail *user_reputation;

// for SecurityQuestion purpose

@property (nonatomic, strong) NSString *phoneNumber;


+ (RKObjectMapping *)mapping;

@property (nonatomic, strong) NSString *seller_status;

@end
