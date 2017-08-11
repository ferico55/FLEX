//
//  SecurityAnswerResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityAnswerResult : NSObject <TKPObjectMapping>

@property(nonatomic, strong, nonnull) NSString* shop_is_gold;
@property(nonatomic, strong, nonnull) NSString* msisdn_is_verified;
@property(nonatomic, strong, nonnull) NSString* shop_id;
@property(nonatomic, strong, nonnull) NSString* shop_name;
@property(nonatomic, strong, nonnull) NSString* full_name;
@property(nonatomic, strong, nonnull) NSString* uuid;
@property(nonatomic, strong, nonnull) NSString* allow_login;
@property(nonatomic, strong, nonnull) NSString* is_login;
@property(nonatomic, strong, nonnull) NSString* user_id;
@property(nonatomic, strong, nonnull) NSString* msisdn_show_dialog;
@property(nonatomic, strong, nonnull) NSString* shop_avatar;
@property(nonatomic, strong, nonnull) NSString* user_image;

@property(nonatomic, strong, nonnull) NSString* change_to_otp;
@property(nonatomic, strong, nonnull) NSString* user_check_security_1;
@property(nonatomic, strong, nonnull) NSString* user_check_security_2;
@property(nonatomic, strong, nonnull) NSString* error;


@end
