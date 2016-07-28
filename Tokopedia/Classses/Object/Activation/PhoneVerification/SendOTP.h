//
//  SendOTP.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendOTPResult.h"

@interface SendOTP : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) SendOTPResult *data;

+(NSDictionary *) attributeMappingDictionary;
+(RKObjectMapping *) mapping;

@end