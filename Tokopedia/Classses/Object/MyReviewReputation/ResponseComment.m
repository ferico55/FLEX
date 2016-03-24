//
//  ResponseComment.m
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResponseComment.h"

@implementation ResponseComment

+ (RKObjectMapping *)mapping {
    RKObjectMapping *responseCommentMapping = [RKObjectMapping mappingForClass:[ResponseComment class]];
    
    [responseCommentMapping addAttributeMappingsFromArray:@[@"status",
                                                            @"message_error",
                                                            @"message_status",
                                                            @"server_process_time"]];
    
    [responseCommentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                           toKeyPath:@"data"
                                                                                         withMapping:[ResponseCommentResult mapping]]];
    
    return responseCommentMapping;
}

@end
