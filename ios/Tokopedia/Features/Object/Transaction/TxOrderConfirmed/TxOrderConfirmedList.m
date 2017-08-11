//
//  TxOrderConfirmedList.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedList.h"

@implementation TxOrderConfirmedList

-(BOOL)isToppayConfirmation{
    return ([self.button[@"button_edit_toppay"] integerValue] == 1);
}


-(NSString *)userBankFullName{
    NSString *bankString = @"";
    if (![_user_bank_name isEqualToString:@""]) {
        bankString = [bankString stringByAppendingFormat:@"%@\n",_user_bank_name];
    }
    
    if (![_user_account_name isEqualToString:@""]) {
        bankString = [bankString stringByAppendingFormat:@"%@\n",_user_account_name];
    }
    
    if (![_user_account_no isEqualToString:@""] && ![_user_account_no isEqualToString:@"0"]) {
        bankString = [bankString stringByAppendingString:_user_account_no];
    }
    
    return bankString;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_count",
                      @"user_account_name",
                      @"user_bank_name",
                      @"payment_date",
                      @"payment_ref_num",
                      @"user_account_no",
                      @"bank_name",
                      @"system_account_no",
                      @"payment_id",
                      @"has_user_bank",
                      @"button",
                      @"payment_amount",
                      @"img_proof_url"
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
