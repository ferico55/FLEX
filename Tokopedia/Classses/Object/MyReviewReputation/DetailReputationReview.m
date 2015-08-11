//
//  DetailReputationReview.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"

@implementation DetailReputationReview

- (DetailReviewReputaionViewModel *)viewModel {
    if(_viewModel == nil) {
        DetailReviewReputaionViewModel *tempViewModel = [DetailReviewReputaionViewModel new];
        tempViewModel.product_rating_point = _product_rating_point;
        tempViewModel.product_name = _product_name;
        tempViewModel.product_rating_point = _product_rating_point;
        tempViewModel.review_create_time = _review_create_time;
        tempViewModel.review_is_skipable = _review_is_skipable;
        tempViewModel.product_uri = _product_uri;
        tempViewModel.product_service_point = _product_service_point;
        tempViewModel.product_accuracy_point = _product_accuracy_point;
        tempViewModel.review_message = _review_message;
        tempViewModel.review_response = _review_response;
        tempViewModel.review_status = _review_status;
        tempViewModel.review_is_allow_edit = _review_is_allow_edit;
        tempViewModel.review_is_skipped = _review_is_skipped;
        tempViewModel.review_update_time = _review_update_time;
        tempViewModel.product_status = _product_status;

        _viewModel = tempViewModel;
    }
    
    return _viewModel;
}
@end
