//
//  DetailReputationReview.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"
#import "ShopBadgeLevel.h"

@implementation DetailReputationReview

- (DetailReviewReputationViewModel *)viewModel {
    if(_viewModel == nil) {
        DetailReviewReputationViewModel *tempViewModel = [DetailReviewReputationViewModel new];
        tempViewModel.product_rating_point = _product_rating_point;
        tempViewModel.product_name = _product_name ?: _review_product_name;
        tempViewModel.product_rating_point = _product_rating_point;
        tempViewModel.review_create_time = _review_create_time;
        tempViewModel.review_is_skipable = _review_is_skipable;
        tempViewModel.product_image = _product_image;
        tempViewModel.product_service_point = _product_service_point;
        tempViewModel.product_accuracy_point = _product_accuracy_point;
        tempViewModel.review_message = _review_message;
        tempViewModel.review_response = _review_response;
        tempViewModel.review_status = _review_status;
        tempViewModel.review_is_allow_edit = _review_is_allow_edit;
        tempViewModel.review_is_skipped = _review_is_skipped;
        tempViewModel.review_update_time = _review_update_time;
        tempViewModel.product_status = _product_status;
        tempViewModel.review_rate_accuracy = _review_rate_accuracy;
        tempViewModel.review_rate_quality = _review_rate_product ?: _review_rate_quality;
        tempViewModel.product_id = _review_product_id;
        tempViewModel.review_is_helpful = _review_is_helpful;
        if(_review_user_name != nil){
            //if coming from product review and shop page
            tempViewModel.review_user_name = _review_user_name;
        }else{
            tempViewModel.review_user_name = _review_full_name;
        }
        if(_review_user_image != nil){
            //if coming from product review and shop page
            tempViewModel.review_user_image = _review_user_image;
        }else{
            //if coming from inbox review
            tempViewModel.review_user_image = _user_image;
        }
        
        tempViewModel.review_image_attachment = _review_image_attachment;

        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}
- (NSString*)shop_name {
    if (_shop_name != nil) {
        return [_shop_name kv_decodeHTMLCharacterEntities];
    } else {
        return [_review_shop_name kv_decodeHTMLCharacterEntities];
    }
}

- (NSString*)product_name {
    if(_product_name != nil){
        return [_product_name kv_decodeHTMLCharacterEntities];
    }else{
        return [_review_product_name kv_decodeHTMLCharacterEntities];
    }
}

- (NSString*)review_message {
    return [_review_message kv_decodeHTMLCharacterEntities];
}

-(NSString *)product_image{
    if(_product_image != nil){
        return _product_image;
    }else{
        return _review_product_image;
    }
}

- (NSString*)review_user_name{
    if(_review_user_name != nil){
        return _review_user_name;
    }else{
        return _review_full_name;
    }
}

-(NSString *)review_user_image{
    if(_review_user_image != nil){
        return _review_user_image;
    }else{
        return _user_image;
    }
}

-(NSString *)product_rating_point{
    if(_product_rating_point != nil){
        return _product_rating_point;
    }else{
        return _review_rate_quality;
    }
}

-(NSString *)product_accuracy_point{
    if(_product_accuracy_point != nil){
        return _product_accuracy_point;
    }else{
        return _review_rate_accuracy;
    }
}

-(NSString *)product_id{
    if(_product_id != nil){
        return _product_id;
    }else{
        return _review_product_id;
    }
}

-(NSString *)review_shop_name{
    if(_review_shop_name != nil){
        return _review_shop_name;
    }else{
        return _product_owner.shop_name;
    }
}

+(RKObjectMapping *)mapping{
    RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
    [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{@"review_update_time"           : @"review_update_time",
                                                                        @"review_rate_accuracy_desc"    : @"review_rate_accuracy_desc",
                                                                        @"review_user_label_id"         : @"review_user_label_id",
                                                                        @"review_user_name"             : @"review_user_name",
                                                                        @"review_rate_accuracy"         : @"review_rate_accuracy",
                                                                        @"review_message"               : @"review_message",
                                                                        @"review_rate_product_desc"     : @"review_rate_product_desc",
                                                                        @"review_rate_speed_desc"       : @"review_rate_speed_desc",
                                                                        @"review_shop_id"               : @"shop_id",
                                                                        @"review_reputation_id"         : @"reputation_id",
                                                                        @"review_user_image"            : @"review_user_image",
                                                                        @"review_user_label"            : @"review_user_label",
                                                                        @"review_create_time"           : @"review_create_time",
                                                                        @"review_id"                    : @"review_id",
                                                                        @"review_rate_service_desc"     : @"review_rate_service_desc",
                                                                        @"review_rate_product"          : @"review_rate_product",
                                                                        @"review_rate_speed"            : @"review_rate_speed",
                                                                        @"review_rate_service"          : @"review_rate_service",
                                                                        @"review_user_id"               : @"review_user_id",
                                                                        @"review_shop_name"             : @"review_shop_name",
                                                                        @"product_images"               : @"product_images",
                                                                        @"review_rate_quality"          : @"review_rate_quality",
                                                                        @"review_product_status"        : @"review_product_status",
                                                                        @"review_is_allow_edit"         : @"review_is_allow_edit",
                                                                        @"review_is_owner"              : @"review_is_owner",
                                                                        @"review_product_name"          : @"review_product_name",
                                                                        @"review_product_id"            : @"review_product_id",
                                                                        @"review_product_image"         : @"review_product_image",
                                                                        
                                                                        @"product_rating_point"         : @"product_rating_point",
                                                                        @"review_is_skipped"            : @"review_is_skipped",
                                                                        @"review_is_skipable"           : @"review_is_skipable",
                                                                        @"product_status"               : @"product_status",
                                                                        @"review_full_name"             : @"review_full_name",
                                                                        @"product_speed_desc"           : @"product_speed_desc",
                                                                        @"review_read_status"           : @"review_read_status",
                                                                        @"product_uri"                  : @"product_uri",
                                                                        @"product_service_desc"         : @"product_service_desc",
                                                                        @"product_speed_point"          : @"product_speed_point",
                                                                        @"review_status"                : @"review_status",
                                                                        @"product_service_point"        : @"product_service_point",
                                                                        @"product_accuracy_point"       : @"product_accuracy_point",
                                                                        @"product_id"                   : @"product_id",
                                                                        @"product_rating_desc"          : @"product_rating_desc",
                                                                        @"product_image"                : @"product_image",
                                                                        @"product_accuracy_desc"        : @"product_accuracy_desc",
                                                                        @"user_image"                   : @"user_image",
                                                                        @"reputation_inbox_id"          : @"reputation_inbox_id",
                                                                        @"user_url"                     : @"user_url",
                                                                        @"shop_name"                    : @"shop_name",
                                                                        @"review_message_edit"          : @"review_message_edit",
                                                                        @"review_post_time"             : @"review_post_time",
                                                                        @"product_name"                 : @"product_name",
                                                                        @"shop_domain"                  : @"shop_domain"
                                                                        }];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation"
                                                                                                  toKeyPath:@"review_user_reputation"
                                                                                                withMapping:[ReputationDetail mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response"
                                                                                                  toKeyPath:@"review_response"
                                                                                                withMapping:[ReviewResponse mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_product_owner"
                                                                                                  toKeyPath:@"product_owner"
                                                                                                withMapping:[ProductOwner mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_badge_level"
                                                                                                  toKeyPath:@"shop_badge_level"
                                                                                                withMapping:[ShopBadgeLevel mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_image_attachment"
                                                                                                  toKeyPath:@"review_image_attachment"
                                                                                                withMapping:[ReviewImageAttachment mapping]]];
    
    return detailReputationReviewMapping;
}

+ (RKObjectMapping *)mappingForInbox {
    RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
    [detailReputationReviewMapping addAttributeMappingsFromArray:@[@"shop_id",
                                                                   @"product_rating_point",
                                                                   @"review_is_skipped",
                                                                   @"review_is_skipable",
                                                                   @"product_status",
                                                                   @"review_full_name",
                                                                   @"review_message",
                                                                   @"review_is_read",
                                                                   @"review_user_label",
                                                                   @"product_speed_desc",
                                                                   @"review_read_status",
                                                                   @"product_uri",
                                                                   @"review_user_id",
                                                                   @"product_service_desc",
                                                                   @"product_speed_point",
                                                                   @"review_status",
                                                                   @"review_update_time",
                                                                   @"product_service_point",
                                                                   @"product_accuracy_point",
                                                                   @"reputation_id",
                                                                   @"product_id",
                                                                   @"product_rating_desc",
                                                                   @"product_image",
                                                                   @"product_accuracy_desc",
                                                                   @"user_image",
                                                                   @"reputation_inbox_id",
                                                                   @"review_create_time",
                                                                   @"user_url",
                                                                   @"shop_name",
                                                                   @"review_message_edit",
                                                                   @"review_id",
                                                                   @"review_post_time",
                                                                   @"review_is_allow_edit",
                                                                   @"product_name",
                                                                   @"shop_domain",
                                                                   @"review_create_time_fmt"
                                                                   ]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation"
                                                                                                  toKeyPath:@"review_user_reputation"
                                                                                                withMapping:[ReputationDetail mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response"
                                                                                                  toKeyPath:@"review_response"
                                                                                                withMapping:[ReviewResponse mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_owner"
                                                                                                  toKeyPath:@"product_owner"
                                                                                                withMapping:[ProductOwner mappingForInbox]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_badge_level"
                                                                                                  toKeyPath:@"shop_badge_level"
                                                                                                withMapping:[ShopBadgeLevel mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_image_attachment"
                                                                                                  toKeyPath:@"review_image_attachment"
                                                                                                withMapping:[ReviewImageAttachment mapping]]];
    
    return detailReputationReviewMapping;
}

+ (RKObjectMapping *)mappingForHelpfulReview {
    RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
    [detailReputationReviewMapping addAttributeMappingsFromArray:@[@"review_user_id",
                                                                   @"review_rate_product_desc",
                                                                   @"review_user_name",
                                                                   @"review_reputation_id",
                                                                   @"review_rate_service_desc",
                                                                   @"review_id",
                                                                   @"review_rate_speed",
                                                                   @"review_rate_service",
                                                                   @"review_update_time",
                                                                   @"review_rate_accuracy_desc",
                                                                   @"review_rate_product",
                                                                   @"review_rate_speed_desc",
                                                                   @"review_shop_id",
                                                                   @"review_create_time",
                                                                   @"review_user_label",
                                                                   @"review_product_id",
                                                                   @"review_message",
                                                                   @"review_user_image",
                                                                   @"review_user_label_id",
                                                                   @"review_rate_accuracy"
                                                                   ]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation"
                                                                                                  toKeyPath:@"review_user_reputation"
                                                                                                withMapping:[ReputationDetail mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response"
                                                                                                  toKeyPath:@"review_response"
                                                                                                withMapping:[ReviewResponse mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_product_owner"
                                                                                                  toKeyPath:@"review_product_owner"
                                                                                                withMapping:[ProductOwner mappingForInbox]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_like_dislike"
                                                                                                  toKeyPath:@"review_like_dislike"
                                                                                                withMapping:[DetailTotalLikeDislike mapping]]];
    
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_image_attachment"
                                                                                                  toKeyPath:@"review_image_attachment"
                                                                                                withMapping:[ReviewImageAttachment mapping]]];
    
    return detailReputationReviewMapping;
}

@end
