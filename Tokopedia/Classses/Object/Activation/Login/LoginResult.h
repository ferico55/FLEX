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
@property (nonatomic) NSInteger shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_avatar;
@property (nonatomic) NSInteger shop_is_gold;

@property (nonatomic) NSInteger user_id;
@property (nonatomic, strong) NSString *full_name;
@property (nonatomic, strong) NSString *user_image;

@property NSInteger status;
@property NSInteger msisdn_is_verified;
@property NSInteger msisdn_show_dialog;

@end
