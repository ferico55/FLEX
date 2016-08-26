//
//  ResolutionProductData.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionProductData.h"

@implementation ResolutionProductData

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ResolutionProductData class]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                            toKeyPath:@"list"
                                                                          withMapping:[ResolutionProductList mapping]]];
    return mapping;
}
@end
