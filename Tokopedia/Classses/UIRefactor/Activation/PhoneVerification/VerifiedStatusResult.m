//
//  VerifiedStatusResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "VerifiedStatusResult.h"

@implementation VerifiedStatusResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[VerifiedStatusResult class]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"msisdn"
                                                                                         toKeyPath:@"msisdn"
                                                                                       withMapping:[VerifiedStatusMSISDN mapping]]];
    
    return resultMapping;
}
@end
