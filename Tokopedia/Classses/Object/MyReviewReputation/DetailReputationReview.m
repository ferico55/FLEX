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
    [detailReputationReviewMapping addAttributeMappingsFromDictionary:@{CReviewUpdateTime:CReviewUpdateTime,
                                                                        CReviewRateAccuracyDesc:CReviewRateAccuracyDesc,
                                                                        CReviewUserLabelID:CReviewUserLabelID,
                                                                        CReviewUserName:CReviewUserName,
                                                                        CReviewRateAccuracy:CReviewRateAccuracy,
                                                                        CReviewMessage:CReviewMessage,
                                                                        CReviewRateProductDesc:CReviewRateProductDesc,
                                                                        CReviewRateSpeedDesc:CReviewRateSpeedDesc,
                                                                        CReviewShopID:CShopID,
                                                                        @"review_reputation_id":CReputationID,
                                                                        CReviewUserImage:CReviewUserImage,
                                                                        CReviewUserLabel:CReviewUserLabel,
                                                                        CReviewCreateTime:CReviewCreateTime,
                                                                        CReviewID:CReviewID,
                                                                        CReviewRateServiceDesc:CReviewRateServiceDesc,
                                                                        CReviewRateProduct:CReviewRateProduct,
                                                                        CReviewRateSpeed:CReviewRateSpeed,
                                                                        CReviewRateService:CReviewRateService,
                                                                        CReviewUserID:CReviewUserID
                                                                        }];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_user_reputation" toKeyPath:@"review_user_reputation" withMapping:[ReputationDetail mapping]]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_response" toKeyPath:@"review_response" withMapping:[ReviewResponse mapping]]];
    [detailReputationReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review_product_owner" toKeyPath:@"product_owner" withMapping:[ProductOwner mapping]]];
    return detailReputationReviewMapping;
}
@end
