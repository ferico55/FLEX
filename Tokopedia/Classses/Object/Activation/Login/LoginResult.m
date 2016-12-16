//
//  LoginResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "LoginResult.h"

@implementation LoginResult

- (NSString *)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LoginResult class]];
    
    [mapping addAttributeMappingsFromArray:@[@"shop_id",
                                             @"is_login",
                                             @"shop_name",
                                             @"shop_avatar",
                                             @"shop_is_gold",
                                             @"user_id",
                                             @"shop_has_terms",
                                             @"full_name",
                                             @"user_image",
                                             @"status",
                                             @"msisdn_is_verified",
                                             @"msisdn_show_dialog"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"security"
                                                                            toKeyPath:@"security"
                                                                          withMapping:[LoginSecurity mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user_reputation"
                                                                            toKeyPath:@"user_reputation"
                                                                          withMapping:[ReputationDetail mapping]]];
    
    return mapping;
}

- (NSString *)seller_status {
    if ([self.shop_id isEqualToString:@""] ||
        [self.shop_id isEqualToString:@"0"]) {
        return @"0";
    } else {
        return @"1";
    }
}

@end
