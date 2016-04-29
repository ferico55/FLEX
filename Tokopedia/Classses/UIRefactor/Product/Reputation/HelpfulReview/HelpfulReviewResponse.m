//
//  HelpfulReviewResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "HelpfulReviewResponse.h"

@implementation HelpfulReviewResponse

+ (RKObjectMapping *)mapping {
    RKObjectMapping *helpfulReviewResponseMapping = [RKObjectMapping mappingForClass:[HelpfulReviewResponse class]];
    
    [helpfulReviewResponseMapping addAttributeMappingsFromArray:@[@"status",
                                                                  @"server_process_time",
                                                                  @"config"]];
    
    [helpfulReviewResponseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                                 toKeyPath:@"data"
                                                                                               withMapping:[HelpfulReviewResult mapping]]];
    
    return helpfulReviewResponseMapping;
}

@end
