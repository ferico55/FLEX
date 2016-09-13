//
//  ResolutionLast.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionLast.h"
#import "Tokopedia-Swift.h"

@implementation ResolutionLast

-(NSArray<ProductTrouble *> *)last_product_trouble{
    return _last_product_trouble?:@[];
}

-(NSString *)last_refund_amt_idr{
    return _last_refund_amt_idr?:@"";
}

-(NSString *)last_solution_string{
    return _last_solution_string?:@"";
}

-(NSString *)last_trouble_string{
    return _last_trouble_string?:@"";
}

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"last_resolution_id",
                      @"last_show_input_addr_button",
                      @"last_action_by",
                      @"last_show_appeal_button",
                      @"last_show_finish_button",
                      @"last_show_input_resi_button",
                      @"last_rival_accepted",
                      @"last_refund_amt_idr",
                      @"last_refund_amt",
                      @"last_user_name",
                      @"last_solution",
                      @"last_user_url",
                      @"last_create_time_str",
                      @"last_trouble_type",
                      @"last_show_accept_admin_button",
                      @"last_show_accept_button",
                      @"last_create_time",
                      @"last_flag_received",
                      @"last_trouble_string",
                      @"last_solution_string",
                      @"last_create_time_wib",
                      @"last_category_trouble_type",
                      @"last_category_trouble_string",
                      @"last_solution_remark"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"last_product_trouble" toKeyPath:@"last_product_trouble" withMapping:[ProductTrouble mapping]];
    [mapping addPropertyMapping:conversationMapping];
    
    return mapping;
}

@end
