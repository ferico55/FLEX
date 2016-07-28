//
//  ProfileEditResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileEditResult.h"

@implementation ProfileEditResult

+(RKObjectMapping *) mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data_user"
                                                                            toKeyPath:@"data_user"
                                                                          withMapping:[DataUser mapping]]];
    
    return mapping;
}

@end
