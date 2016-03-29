//
//  ReviewProductOwner.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewProductOwner.h"

@implementation ReviewProductOwner
+(RKObjectMapping *)mapping{
    RKObjectMapping *reviewProductOwnerMapping = [RKObjectMapping mappingForClass:[ReviewProductOwner class]];
    [reviewProductOwnerMapping addAttributeMappingsFromArray:@[@"user_id", @"user_image", @"user_name"]];
    return reviewProductOwnerMapping;
}
@end
