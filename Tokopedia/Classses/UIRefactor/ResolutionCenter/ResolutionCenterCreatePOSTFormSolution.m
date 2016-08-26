//
//  ResolutionCenterCreatePOSTFormSolution.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreatePOSTFormSolution.h"

@implementation ResolutionCenterCreatePOSTFormSolution

+(RKObjectMapping *)mapping{
    RKObjectMapping* solutionMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreatePOSTFormSolution class]];
    [solutionMapping addAttributeMappingsFromArray:@[@"refund_type",
                                                     @"show_refund_box",
                                                     @"max_refund",
                                                     @"max_refund_idr",
                                                     @"solution_text",
                                                     @"solution_id",
                                                     @"refund_text_desc"
                                                     ]];
    return solutionMapping;
}
@end
