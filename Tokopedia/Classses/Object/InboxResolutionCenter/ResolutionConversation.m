//
//  ResolutionConversation.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionConversation.h"
#import "Tokopedia-Swift.h"

@implementation ResolutionConversation

- (NSString *)remark_str {
    if ([_remark_str isEqualToString:@"0"]){
        return @"";
    }
    return [_remark_str kv_decodeHTMLCharacterEntities];
}

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"remark",
                      @"conversation_id",
                      @"time_ago",
                      @"create_time",
                      @"refund_amt",
                      @"flag_received",
                      @"user_url",
                      @"create_time_wib",
                      @"user_name",
                      @"user_img",
                      @"solution",
                      @"remark_str",
                      @"input_resi",
                      @"kurir_name",
                      @"input_kurir",
                      @"edit_resi",
                      @"track_resi",
                      @"trouble_type",
                      @"refund_amt_idr",
                      @"action_by",
                      @"solution_flag",
                      @"system_flag",
                      @"left_count",
                      @"view_more",
                      @"isAddedConversation",
                      @"address_edited",
                      @"edit_address",
                      @"trouble_string",
                      @"solution_string"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}
//+ (NSDictionary *)attributeMappingDictionary {
//    return @{ @"conversation_remark"            : @"remark",
//              @"conversation_conversation_id"   : @"conversation_id",
//              @"conversation_time_ago"          : @"time_ago",
//              @"conversation_create_time"       : @"create_time",
//              @"conversation_refund_amt"        : @"refund_amt",
//              @"conversation_flag_received"     : @"flag_received",
//              @"conversation_user_url"          : @"user_url",
//              @"conversation_create_time_wib"   : @"create_time_wib",
//              @"conversation_user_name"         : @"user_name",
//              @"conversation_user_img"          : @"user_img",
//              @"conversation_solution"          : @"solution",
//              @"conversation_remark_string"     : @"remark_string",
//              @"conversation_input_resi"        : @"input_resi",
//              @"conversation_kurir_name"        : @"kurir_name",
//              @"conversation_input_kurir"       : @"input_kurir",
//              @"conversation_show_edit_resi_button" : @"show_edit_resi_button",
//              @"conversation_show_track_button"     : @"show_track_button",
//              @"conversation_trouble_type"          : @"trouble_type",
//              @"conversation_refund_amt_idr"        : @"refund_amt_idr",
//              @"conversation_action_by"         : @"action_by",
//              @"conversation_solution_flag"     : @"solution_flag",
//              @"conversation_system_flag"       : @"system_flag",
//              @"conversation_left_count"        : @"left_count",
//              @"conversation_view_more"         : @"view_more",
//              @"conversation_address_edited"    : @"address_edited",
//              @"conversation_show_edit_addr_button" : @"show_edit_addr_button",
//              @"conversation_trouble_string"    : @"trouble_string",
//              @"conversation_solution_string"   : @"solution_string"
//              };
//}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachment" toKeyPath:@"attachment" withMapping:[ResolutionAttachment mapping]];
    [mapping addPropertyMapping:conversationMapping];
    
    RKRelationshipMapping *productMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"product_trouble" toKeyPath:@"product_trouble" withMapping:[ProductTrouble mapping]];
    [mapping addPropertyMapping:productMapping];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:[AddressFormList mapping]]];
    
    return mapping;
}


@end
