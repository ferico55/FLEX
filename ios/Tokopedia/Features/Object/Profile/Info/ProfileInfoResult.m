//
//  ProfileInfoResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileInfoResult.h"

@implementation ProfileInfoResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ProfileInfoResult class]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user_info"
                                                                            toKeyPath:@"user_info"
                                                                          withMapping:[UserInfo mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_stats"
                                                                            toKeyPath:@"shop_stats"
                                                                          withMapping:[ShopStats mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_info"
                                                                            toKeyPath:@"shop_info"
                                                                          withMapping:[ShopInfo mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"respond_speed"
                                                                            toKeyPath:@"respond_speed"
                                                                          withMapping:[ResponseSpeed mapping]]];
    
    return mapping;
}

@end
