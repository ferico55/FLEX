//
//  ShippingContact.h
//  Tokopedia
//
//  Created by Tokopedia on 1/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShippingContact : NSObject

@property (strong, nonatomic) NSString *msisdn_verification;
@property (strong, nonatomic) NSString *messenger_enc;
@property (strong, nonatomic) NSString *user_email_enc;
@property (strong, nonatomic) NSString *msisdn_enc;

@end
