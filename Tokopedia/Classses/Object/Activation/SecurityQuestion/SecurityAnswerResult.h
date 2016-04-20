//
//  SecurityAnswerResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityAnswerResult : NSObject <TKPObjectMapping>

@property(nonatomic, strong) NSString* shop_is_gold;
@property(nonatomic, strong) NSString* msisdn_is_verified;
@property(nonatomic, strong) NSString* shop_id;
@property(nonatomic, strong) NSString* shop_name;
@property(nonatomic, strong) NSString* full_name;
@property(nonatomic, strong) NSString* uuid;
@property(nonatomic, strong) NSString* allow_login;
@property(nonatomic, strong) NSString* user_id;
@property(nonatomic, strong) NSString* msisdn_show_dialog;
@property(nonatomic, strong) NSString* shop_avatar;
@property(nonatomic, strong) NSString* user_image;

@end
