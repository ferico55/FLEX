//
//  ResolutionCenterCreateSolutionList.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateSolutionList.h"

@implementation ResolutionCenterCreateSolutionList
+(RKObjectMapping *)mapping{
    RKObjectMapping* solutionListMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateSolutionList class]];
    [solutionListMapping addAttributeMappingsFromArray:@[@"refund_type",
                                                         @"attachment",
                                                         @"solution_text",
                                                         @"solution_id"
                                                         ]];
    return solutionListMapping;
}
@end
