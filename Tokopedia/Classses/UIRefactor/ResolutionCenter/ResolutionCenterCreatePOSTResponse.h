//
//  ResolutionCenterCreatePOSTResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionCenterCreatePOSTData.h"

@interface ResolutionCenterCreatePOSTResponse : NSObject
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) NSString* server_process_time;
@property (strong, nonatomic) ResolutionCenterCreatePOSTData* data;

+(RKObjectMapping*)mapping;
@end
