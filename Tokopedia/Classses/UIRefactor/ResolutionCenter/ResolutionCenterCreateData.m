//
//  ResolutionCenterCreateData.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateData.h"

@implementation ResolutionCenterCreateData
+(RKObjectMapping *)mapping{
    RKObjectMapping* dataMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateData class]];
    [dataMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list_ts"
                                                                                toKeyPath:@"list_ts"
                                                                              withMapping:[ResolutionCenterCreateList mapping]]];
    [dataMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"form"
                                                                                toKeyPath:@"form"
                                                                              withMapping:[ResolutionOrder mapping]]];
    return dataMapping;
}
@end
