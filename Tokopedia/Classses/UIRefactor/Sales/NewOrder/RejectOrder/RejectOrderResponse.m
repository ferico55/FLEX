//
//  RejectOrderResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectOrderResponse.h"

@implementation RejectOrderResponse
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RejectOrderResponse class]];
    [mapping addAttributeMappingsFromArray:@[@"status",@"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[RejectReasonData mapping]]];
    
    return mapping;
}
@end
