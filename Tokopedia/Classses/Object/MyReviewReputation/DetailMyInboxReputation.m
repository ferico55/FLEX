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
        viewModel.role = _role;
        viewModel.seller_score = _seller_score;
        viewModel.buyer_score = _buyer_score;
        viewModel.updated_reputation_review = _updated_reputation_review;
        viewModel.score_edit_time_fmt = _score_edit_time_fmt;
        viewModel.reputation_score = _reputation_score;
        viewModel.user_reputation = _user_reputation;
        viewModel.shop_badge_level = _shop_badge_level;
        viewModel.auto_read = _auto_read;
        viewModel.reputation_progress = _reputation_progress;
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}
@end
