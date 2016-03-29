//
//  RequestObject.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestObjectGetAddress : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *per_page;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *query;

@end

@interface RequestObjectEditAddress : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *address_id;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *receiver_name;
@property (nonatomic, strong) NSString *address_name;
@property (nonatomic, strong) NSString *receiver_phone;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *postal_code;
@property (nonatomic, strong) NSString *address_street;
@property (nonatomic, strong) NSString *user_password;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *is_from_cart;
@property (nonatomic, strong) NSString *password;

@end

@interface RequestObjectUploadImage : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *image_id;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *payment_id;
@property (nonatomic, strong) NSString *action;

@end