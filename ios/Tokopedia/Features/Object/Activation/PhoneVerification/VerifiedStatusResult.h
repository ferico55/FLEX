//
//  VerifiedStatusResult.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VerifiedStatusMSISDN.h"
@interface VerifiedStatusResult : NSObject

@property (strong, nonatomic, nonnull) VerifiedStatusMSISDN* msisdn;

+ (RKObjectMapping *_Nonnull)mapping;

@end
