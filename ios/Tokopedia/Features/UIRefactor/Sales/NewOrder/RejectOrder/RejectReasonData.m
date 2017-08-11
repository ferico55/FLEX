//
//  RejectReasonData.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonData.h"

@implementation RejectReasonData
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RejectReasonData class]];    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reason"
                                                                            toKeyPath:@"reason"
                                                                          withMapping:[RejectReason mapping]]];
    return mapping;
}
@end
