//
//  DetailMyReviewReputation.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailMyInboxReputation.h"
#import "MyReviewReputationViewModel.h"

@implementation DetailMyInboxReputation

- (MyReviewReputationViewModel *)viewModel
{
    if(_viewModel == nil) {
        MyReviewReputationViewModel *viewModel = [MyReviewReputationViewModel new];
        viewModel.reviewee_name = _reviewee_name;
        viewModel.reviewee_score = _reviewee_score;
        viewModel.reviewee_role = _reviewee_role;
        viewModel.invoice_ref_num = _invoice_ref_num;
        viewModel.show_reviewee_score = _show_reviewee_score;
        viewModel.reviewee_picture = _reviewee_picture;
        viewModel.reviewee_uri = _reviewee_uri;
        viewModel.read_status = _read_status;
        viewModel.reviewee_score_status = _reviewee_score_status;
        viewModel.show_bookmark = _show_bookmark;
        viewModel.unassessed_reputation_review = _unassessed_reputation_review;
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}
@end
