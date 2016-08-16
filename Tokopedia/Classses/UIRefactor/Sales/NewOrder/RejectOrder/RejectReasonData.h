//
//  RejectReasonData.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RejectReason.h"

@interface RejectReasonData : NSObject

@property(strong, nonatomic) NSArray* reason;

+(RKObjectMapping*)mapping;
@end
