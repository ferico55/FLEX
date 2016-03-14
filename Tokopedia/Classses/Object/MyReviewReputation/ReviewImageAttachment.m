//
//  ReviewImageAttachment.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewImageAttachment.h"

@implementation ReviewImageAttachment

+ (RKObjectMapping *)mapping {
    RKObjectMapping *reviewImageAttachmentMapping = [RKObjectMapping mappingForClass:[ReviewImageAttachment class]];
    
    [reviewImageAttachmentMapping addAttributeMappingsFromDictionary:@{@"desc" : @"description",
                                                                       @"uri_large" : @"uri_large",
                                                                       @"attachment_id" : @"attachment_id",
                                                                       @"uri_thumbnail" : @"uri_thumbnail"}];
    
    return reviewImageAttachmentMapping;
}

@end
