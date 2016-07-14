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
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) VerifiedStatusResult *result;
+(RKObjectMapping*)mapping;
@end
