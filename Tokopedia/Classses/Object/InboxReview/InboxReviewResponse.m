//
//  InboxReviewResponse.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxReviewResponse.h"

@implementation InboxReviewResponse

- (NSString*)response_message {
    return [_response_message kv_decodeHTMLCharacterEntities];
}

@end
