//
//  ResolutionCenterCreatePOSTRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreatePOSTRequest.h"

@implementation ResolutionCenterCreatePOSTRequest
+(RKObjectMapping *)mapping{
    RKObjectMapping *requestMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreatePOSTRequest class]];
    [requestMapping addAttributeMappingsFromArray:@[@"category_trouble_id", @"order_id"]];
    [requestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_list"
                                                                                  toKeyPath:@"product_list"
                                                                                 withMapping:[ResolutionCenterCreatePOSTProduct mapping]]];
    return requestMapping;
}
@end
