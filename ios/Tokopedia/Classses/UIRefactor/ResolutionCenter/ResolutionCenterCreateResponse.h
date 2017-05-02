//
//  ResolutionCenterCreateResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreateData.h"

@interface ResolutionCenterCreateResponse : NSObject
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) NSString* server_process_time;
@property (strong, nonatomic) ResolutionCenterCreateData* data;

+(RKObjectMapping*)mapping;
@end
