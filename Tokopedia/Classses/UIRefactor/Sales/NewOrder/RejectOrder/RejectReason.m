//
//  RejectReason.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReason.h"

@implementation RejectReason
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RejectReason class]];
    [mapping addAttributeMappingsFromArray:@[@"reason_code", @"reason_text"]];
    return mapping;
}
@end
