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

@property(nonatomic, strong, nonnull) NSString* status;
@property(nonatomic, strong, nonnull) NSArray* message_error;
@property(nonatomic, strong, nonnull) NSArray* message_status;
@property(nonatomic, strong, nonnull) SecurityRequestOTPResult* data;

@end
