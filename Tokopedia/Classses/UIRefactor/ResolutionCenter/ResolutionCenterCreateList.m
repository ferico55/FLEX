//
//  ResolutionCenterCreateList.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateList.h"

@implementation ResolutionCenterCreateList
+(RKObjectMapping *)mapping{
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateList class]];
    [listMapping addAttributeMappingsFromArray:@[@"category_trouble_id",
                                                 @"category_trouble_text"
                                                 ]];
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"trouble_list"
                                                                               toKeyPath:@"trouble_list"
                                                                              withMapping:[ResolutionCenterCreateTroubleList mapping]]];
    return listMapping;
}
@end
