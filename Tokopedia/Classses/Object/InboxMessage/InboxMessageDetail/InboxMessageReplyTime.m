//
//  InboxMessageReplyTime.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageReplyTime.h"

@implementation InboxMessageReplyTime

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[
                                                 @"unix",
                                                 @"formatted",
                                                 ]];

    
    return mapping;
}

@end
