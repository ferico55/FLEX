//
//  ClosedScheduleDetail.m
//  Tokopedia
//
//  Created by Johanes Effendi on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ClosedScheduleDetail.h"

@implementation ClosedScheduleDetail
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"close_end", @"close_start", @"close_status"]];
    return mapping;
}
@end
