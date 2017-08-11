//
//  MyReviewReputationViewModel.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReputationDetail, ShopBadgeLevel;

@interface MyReviewReputationViewModel : NSObject
@property (nonatomic, strong) NSString *invoice_ref_num, *invoice_uri, *reviewee_name, *seller_score, *reviewee_score, *reviewee_picture, *reviewee_role, *show_reviewee_score, *reviewee_uri, *read_status, *reviewee_score_status, *show_bookmark, *unassessed_reputation_review, *role, *buyer_score, *score_edit_time_fmt, *updated_reputation_review, *reputation_score, *auto_read, *reputation_progress;

@property (nonatomic, strong) NSString* their_score_image;
@property (nonatomic, strong) NSString* my_score_image;

//app's flag for reputation which been edited
@property (nonatomic, strong) NSString *just_updated;

@property (nonatomic, strong) ShopBadgeLevel *shop_badge_level;
@property (nonatomic, strong) ReputationDetail *user_reputation;
@end
