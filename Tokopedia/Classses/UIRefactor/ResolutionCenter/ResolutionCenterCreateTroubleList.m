//
//  ResolutionCenterCreateTroubleList.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateTroubleList.h"

@implementation ResolutionCenterCreateTroubleList
+(RKObjectMapping *)mapping{
    RKObjectMapping* troubleListMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateTroubleList class]];
    [troubleListMapping addAttributeMappingsFromArray:@[@"trouble_text",
                                                        @"trouble_id"
                                                        ]];
    return troubleListMapping;
}
@end
