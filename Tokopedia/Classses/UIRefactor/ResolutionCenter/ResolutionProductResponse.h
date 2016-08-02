//
//  ResolutionProductResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionProductData.h"

@interface ResolutionProductResponse : NSObject
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) NSString* server_process_time;
@property (strong, nonatomic) ResolutionProductData* data;

+(RKObjectMapping*)mapping;
@end
