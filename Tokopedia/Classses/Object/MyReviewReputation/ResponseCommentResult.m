//
//  ResponseCommentResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResponseCommentResult.h"

@implementation ResponseCommentResult

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *responseCommentResultMapping = [RKObjectMapping mappingForClass:[ResponseCommentResult class]];
    
    [responseCommentResultMapping addAttributeMappingsFromArray:@[@"is_owner",
                                                                  @"reputation_review_counter",
                                                                  @"is_success",
                                                                  @"show_bookmark",
                                                                  @"review_id",
                                                                  @"shop_id",
                                                                  @"shop_name",
                                                                  @"shop_img_url"]];
    
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_owner"
                                                                                                 toKeyPath:@"product_owner"
                                                                                               withMapping:[ProductOwner mapping]]];
    
    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response"
                                                                                                 toKeyPath:@"review_response"
                                                                                               withMapping:[ReviewResponse mapping]]];

    [responseCommentResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_reputation"
                                                                                                 toKeyPath:@"shop_reputation"
                                                                                               withMapping:[ShopReputation mapping]]];

    
    
    return responseCommentResultMapping;
}

@end
