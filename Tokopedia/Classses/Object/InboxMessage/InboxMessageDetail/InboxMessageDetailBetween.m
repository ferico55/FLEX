//
//  InboxMessageDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailBetween.h"
#import "inbox.h"

@implementation InboxMessageDetailBetween

+ (RKObjectMapping *)mapping {
    RKObjectMapping *betweenMapping = [RKObjectMapping mappingForClass:[InboxMessageDetailBetween class]];
    [betweenMapping addAttributeMappingsFromArray:@[
                                                    KTKPDMESSAGE_USERIDKEY,
                                                    KTKPDMESSAGE_USERNAMEKEY
                                                    ]];
    return betweenMapping;
}

@end
