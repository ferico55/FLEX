//
//  Errors.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 6/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "Errors.h"

@implementation Errors

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Errors class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
                                                  @"title" : @"title",
                                                  @"description" : @"desc"
                                                  }];
    
    return mapping;
}

@end
