//
//  ProductTalkForm.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkForm.h"

@implementation ProductTalkForm : NSObject

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductTalkForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKRelationshipMapping *resulRel = [ProductTalkFormResult mapping];

    [statusMapping addPropertyMapping:resulRel];
    return statusMapping;
}
@end
