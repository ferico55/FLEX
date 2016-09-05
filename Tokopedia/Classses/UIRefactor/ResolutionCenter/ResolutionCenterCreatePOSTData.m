//
//  ResolutionCenterCreatePOSTData.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreatePOSTData.h"
#import "Tokopedia-Swift.h"

@implementation ResolutionCenterCreatePOSTData
+(RKObjectMapping *)mapping{
    RKObjectMapping* dataMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreatePOSTData class]];
    [dataMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"form_solution"
                                                                               toKeyPath:@"form_solution"
                                                                             withMapping:[EditSolution mapping]]];
    return dataMapping;
}
@end
