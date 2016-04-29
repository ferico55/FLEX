//
//  DetailMyReviewReputation.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailMyInboxReputation.h"
#import "MyReviewReputationViewModel.h"
#import "ShopBadgeLevel.h"
#import "ReputationDetail.h"

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
        viewModel.my_score_image = _my_score_image;
        viewModel.their_score_image = _their_score_image;
        
        _viewModel = viewModel;
    }
    
    return _viewModel;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *detailMyInboxReputationMapping = [RKObjectMapping mappingForClass:[DetailMyInboxReputation class]];
    
    [detailMyInboxReputationMapping addAttributeMappingsFromArray:@[@"their_score_image",
                                                                    @"create_time_fmt",
                                                                    @"invoice_uri",
                                                                    @"review_status_description",
                                                                    @"order_id",
                                                                    @"reviewee_role",
                                                                    @"buyer_id",
                                                                    @"invoice_ref_num",
                                                                    @"shop_id",
                                                                    @"create_time_ago",
                                                                    @"reviewee_name",
                                                                    @"read_status",
                                                                    @"buyer_score",
                                                                    @"inbox_id",
                                                                    @"my_score_image",
                                                                    @"role",
                                                                    @"reviewee_picture",
                                                                    @"is_reviewer_score_edited",
                                                                    @"reputation_progress",
                                                                    @"auto_read",
                                                                    @"show_reviewee_score",
                                                                    @"reviewee_score",
                                                                    @"reviewee_score_status",
                                                                    @"reputation_id",
                                                                    @"updated_reputation_review",
                                                                    @"unassessed_reputation_review",
                                                                    @"is_edited",
                                                                    @"reputation_days_left_fmt",
                                                                    @"reputation_inbox_id",
                                                                    @"show_reputation_day",
                                                                    @"score_edit_time_fmt",
                                                                    @"is_reviewee_score_edited",
                                                                    @"reviewee_uri",
                                                                    @"seller_score",
                                                                    @"reputation_days_left",
                                                                    @"reputation_score",
                                                                    @"show_bookmark",
                                                                    @"create_time_fmt_ws"]];
    
    [detailMyInboxReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user_reputation"
                                                                                                   toKeyPath:@"user_reputation"
                                                                                                 withMapping:[ReputationDetail mapping]]];
    
    [detailMyInboxReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_badge_level"
                                                                                                   toKeyPath:@"shop_badge_level"
                                                                                                 withMapping:[ShopBadgeLevel mapping]]];
    
    return detailMyInboxReputationMapping;
}

@end
