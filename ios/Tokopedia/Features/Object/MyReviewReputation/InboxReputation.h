//
//  InboxReputation.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxReputationResult.h"

@interface InboxReputation : NSObject
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) InboxReputationResult *data;

+ (RKObjectMapping*)mapping;

@end
