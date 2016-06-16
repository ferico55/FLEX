//
//  ReviewResponse.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewResponse.h"

@implementation ReviewResponse

- (NSString*)response_message {
    return [_response_message kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping{
    RKObjectMapping *reviewResponseMapping = [RKObjectMapping mappingForClass:[ReviewResponse class]];
    [reviewResponseMapping addAttributeMappingsFromArray:@[@"response_create_time",
                                                           @"response_message",
                                                           @"response_time_fmt",
                                                           @"response_time_ago",
                                                           @"response_msg"]];
    return reviewResponseMapping;
}

@end
