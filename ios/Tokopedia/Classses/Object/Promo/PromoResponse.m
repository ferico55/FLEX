//
//  PromoResponse.m
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoResponse.h"

@implementation PromoResponse

+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PromoResponse class]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"data"
                                                                                withMapping:[PromoResult mapping]]];
    return statusMapping;
}

@end
