//
//  RejectOrderResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RejectReasonData.h"

@interface RejectOrderResponse : NSObject
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) RejectReasonData *data;

+(RKObjectMapping*)mapping;
@end
