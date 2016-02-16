//
//  InboxMessageDetailList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailList.h"
#import "inbox.h"

@implementation InboxMessageDetailList

- (NSString*)message_reply {
    return [_message_reply kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 KTKPDMESSAGE_ACTIONKEY,
                                                 KTKPDMESSAGE_CREATEBYKEY,
                                                 KTKPDMESSAGE_REPLYKEY,
                                                 KTKPDMESSAGE_REPLYIDKEY
                                                 KTKPDMESSAGE_BUTTONSPAMKEY,
                                                 KTKPDMESSAGE_REPLYTIMEKEY,
                                                 KTKPDMESSAGE_ISMODKEY,
                                                 KTKPDMESSAGE_USERIDKEY,
                                                 KTKPDMESSAGE_USERNAMEKEY,
                                                 KTKPDMESSAGE_USERIMAGEKEY,
                                                 KTKPDMESSAGE_USER_LABEL,
                                                 KTKPDMESSAGE_USER_LABEL_ID
                                                 ]];
    
    return listMapping;
}

@end
