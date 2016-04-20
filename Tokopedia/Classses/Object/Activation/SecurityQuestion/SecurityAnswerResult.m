//
//  SecurityAnswerResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityAnswerResult.h"

@implementation SecurityAnswerResult

+(RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"shop_is_gold", @"msisdn_is_verified", @"shop_id", @"shop_name", @"full_name", @"uuid", @"allow_login", @"is_login", @"user_id", @"msisdn_show_dialog", @"shop_avatar", @"user_image"]];
    
    return mapping;
}


@end
