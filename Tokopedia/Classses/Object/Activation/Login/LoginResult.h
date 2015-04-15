//
//  LoginResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResult : NSObject //<NSCoding>

@property (nonatomic) BOOL is_login;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_avatar;
@property (nonatomic) NSInteger shop_is_gold;

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *device_token_id;
@property (nonatomic, strong) NSString *full_name;
@property (nonatomic, strong) NSString *user_image;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *msisdn_is_verified;
@property (nonatomic, strong) NSString *msisdn_show_dialog;

@end