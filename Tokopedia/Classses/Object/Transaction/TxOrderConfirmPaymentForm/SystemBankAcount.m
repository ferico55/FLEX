//
//  SystemBankAcount.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SystemBankAcount.h"

@implementation SystemBankAcount
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"sysbank_account_number",
                      @"sysbank_account_name",
                      @"sysbank_name",
                      @"sysbank_note",
                      @"sysbank_id",
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
