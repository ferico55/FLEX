//
//  InboxMessageDetailList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailList.h"

@implementation InboxMessageDetailList

- (NSString*)message_reply {
    return [_message_reply kv_decodeHTMLCharacterEntities];
}

@end
