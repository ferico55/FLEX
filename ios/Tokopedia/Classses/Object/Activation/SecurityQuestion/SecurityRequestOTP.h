//
//  SecurityRequestOTP.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurityRequestOTPResult.h"

@interface SecurityRequestOTP : NSObject <TKPObjectMapping>

@property(nonatomic, strong) NSString* status;
@property(nonatomic, strong) NSArray* message_error;
@property(nonatomic, strong) NSArray* message_status;
@property(nonatomic, strong) SecurityRequestOTPResult* data;

@end
