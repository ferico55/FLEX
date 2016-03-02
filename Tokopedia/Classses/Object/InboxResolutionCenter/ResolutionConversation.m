//
//  ResolutionConversation.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionConversation.h"

@implementation ResolutionConversation

- (NSString *)remark_str {
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
                      @"show_edit_resi_button",
                      @"show_track_button",
                      @"trouble_type",
                      @"refund_amt_idr",
                      @"action_by",
                      @"solution_flag",
                      @"system_flag",
                      @"left_count",
                      @"view_more",
                      @"isAddedConversation",
                      @"address_edited",
                      @"show_edit_addr_button",
                      @"trouble_string",
                      @"solution_string"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachment" toKeyPath:@"attachment" withMapping:[ResolutionAttachment mapping]];
    [mapping addPropertyMapping:conversationMapping];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"address" toKeyPath:@"address" withMapping:[AddressFormList mapping]]];
    
    return mapping;
}


@end
