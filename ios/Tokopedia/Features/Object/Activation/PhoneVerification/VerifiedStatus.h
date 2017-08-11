//
//  VerifiedStatus.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VerifiedStatusResult.h"

@interface VerifiedStatus : NSObject
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) VerifiedStatusResult *result;

+ (RKObjectMapping *_Nonnull)mapping;

@end
