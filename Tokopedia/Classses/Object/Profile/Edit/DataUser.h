//
//  DataUser.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUser : NSObject <TKPObjectMapping>

@property (nonatomic, strong)NSString *hobby;
@property (nonatomic, strong)NSString *birth_day;
@property (nonatomic, strong)NSString *user_messenger;
@property (nonatomic, strong)NSString *full_name;
@property (nonatomic, strong)NSString *birth_month;
@property (nonatomic, strong)NSString *user_email;
@property (nonatomic, strong)NSString *birth_year;
@property (nonatomic, strong)NSString *user_phone;
@property (nonatomic, strong)NSString *gender;
@property (nonatomic, strong)NSString *user_image;

+(NSDictionary *) attributeMappingDictionary;
+(RKObjectMapping *) mapping;

@end
