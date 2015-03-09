//
//  InboxResolutionCenterObjectMapping.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InboxResolutionCenter.h"
#import "ResolutionCenterDetail.h"
#import "string_inbox_resolution_center.h"

@interface InboxResolutionCenterObjectMapping : NSObject

-(RKObjectMapping*)resolutionLastMapping;
-(RKObjectMapping*)resolutionOrderMapping;
-(RKObjectMapping*)resolutionByMapping;
-(RKObjectMapping*)resolutionShopMapping;
-(RKObjectMapping*)resolutionCustomerMapping;
-(RKObjectMapping*)resolutionDisputeMapping;
-(RKObjectMapping*)resolutionConversationMapping;
-(RKObjectMapping*)resolutionAttachmentMapping;
-(RKObjectMapping*)resolutionButtonMapping;

@end
