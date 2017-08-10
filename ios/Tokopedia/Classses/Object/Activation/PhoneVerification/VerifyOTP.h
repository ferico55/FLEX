//
//  VerifyOTP.h
//  Tokopedia
//
//  Created by Johanes Effendi on 11/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VerifyOTPResult.h"

@interface VerifyOTP : NSObject

@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) VerifyOTPResult *data;

@end
