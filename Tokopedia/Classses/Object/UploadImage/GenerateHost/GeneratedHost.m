//
//  GeneratedHost.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneratedHost.h"

@implementation GeneratedHost

+ (RKObjectMapping *)mapping {
    RKObjectMapping *generatedHostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    
    [generatedHostMapping addAttributeMappingsFromArray:@[@"server_id",
                                                          @"upload_host",
                                                          @"user_id"]];
    
    return generatedHostMapping;
}

@end
