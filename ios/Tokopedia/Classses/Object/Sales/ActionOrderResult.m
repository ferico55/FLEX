//
//  ActionOrderResult.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ActionOrderResult.h"

@implementation ActionOrderResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"is_success"]];
    return mapping;
}

- (BOOL)isOrderAccepted {
    return [self.is_success isEqualToString: @"1"];
}

@end
