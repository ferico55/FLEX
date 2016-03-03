//
//  DetailReputationReview.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"

@implementation DetailReputationReview

- (DetailReviewReputationViewModel *)viewModel {
    if(_viewModel == nil) {
        DetailReviewReputationViewModel *tempViewModel = [DetailReviewReputationViewModel new];
        tempViewModel.product_rating_point = _product_rating_point;
        tempViewModel.product_name = _product_name;
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
        tempViewModel.review_rate_quality = _review_rate_product;
        tempViewModel.review_user_name = _review_user_name;
        tempViewModel.review_user_image = _review_user_image;

        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)review_message {
    return [_review_message kv_decodeHTMLCharacterEntities];
}

+(RKObjectMapping *)mapping{
    RKObjectMapping *detailReputationReviewMapping = [RKObjectMapping mappingForClass:[DetailReputationReview class]];
    [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{@"review_update_time":@"review_update_time",
                                                                        @"review_rate_accuracy_desc":@"review_rate_accuracy_desc",
                                                                        @"review_user_label_id":@"review_user_label_id",
                                                                        @"review_user_name":@"review_user_name",
                                                                        @"review_rate_accuracy":@"review_rate_accuracy",
                                                                        @"review_message":@"review_message",
                                                                        @"review_rate_product_desc":@"review_rate_product_desc",
                                                                        @"review_rate_speed_desc":@"review_rate_speed_desc",
                                                                        @"review_shop_id":@"shop_id",
                                                                        @"review_reputation_id":@"reputation_id",
                                                                        @"review_user_image":@"review_user_image",
                                                                        @"review_user_label":@"review_user_label",
                                                                        @"review_create_time":@"review_create_time",
                                                                        @"review_id":@"review_id",
                                                                        @"review_rate_service_desc":@"review_rate_service_desc",
                                                                        @"review_rate_product":@"review_rate_product",
                                                                        @"review_rate_speed":@"review_rate_speed",
                                                                        @"review_rate_service":@"review_rate_service",
                                                                        @"review_user_id":@"review_user_id",
                                                                        @"review_shop_name":@"review_shop_name",
                                                                        @"product_images":@"product_images",
                                                                        @"review_rate_quality":@"review_rate_quality",
                                                                        @"review_product_status":@"review_product_status",
                                                                        @"review_is_allow_edit":@"review_is_allow_edit",
                                                                        @"review_is_owner":@"review_is_owner",
                                                                        @"review_product_name":@"review_product_name",
                                                                        @"review_product_id":@"review_product_id",
                                                                        @"review_product_image":@"review_product_image"
                                                                        }];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation" toKeyPath:@"review_user_reputation" withMapping:[ReputationDetail mapping]]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response" toKeyPath:@"review_response" withMapping:[ReviewResponse mapping]]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_product_owner" toKeyPath:@"product_owner" withMapping:[ProductOwner mapping]]];
    return detailReputationReviewMapping;
}
@end
