//
//  DetailMyReviewReputation.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CValueRead @"1"
#define CValueUnRead @"2"

#define CRevieweeScoreStatus @"reviewee_score_status"
#define CShopID @"shop_id"
#define CBuyerScrore @"buyer_score"
#define CRevieweePicture @"reviewee_picture"
#define CRevieweeName @"reviewee_name"
#define CCreateTimeFmt @"create_time_fmt"
#define CReputationID @"reputation_id"
#define CRevieweeUri @"reviewee_uri"
#define CRevieweeScore @"reviewee_score"
#define CSellerScore @"seller_score"
#define CInboxID @"inbox_id"
#define CInvoiceRefNum @"invoice_ref_num"
#define CInvoiceUri @"invoice_uri"
#define CReadStatus  @"read_status"
#define CCreateTimeAgo @"create_time_ago"
#define CRevieweeRole @"reviewee_role"
#define COrderID @"order_id"
#define CUnaccessedReputationReview @"unassessed_reputation_review"
#define CShowRevieweeSCore @"show_reviewee_score"
#define CRole @"role"
#define CShowBookmark @"show_bookmark"
#define CReputationScore @"reputation_score"
#define CUpdatedReputationReview @"updated_reputation_review"
#define CScoreEditTimeFmt @"score_edit_time_fmt"
#define CReputationInboxID @"reputation_inbox_id"
#define CUserReputation @"user_reputation"
#define CShopBadgeLevel @"shop_badge_level"
@class DetailMyInboxReputation, MyReviewReputationViewModel, ReputationDetail, ShopBadgeLevel;

@interface DetailMyInboxReputation : NSObject
@property (nonatomic, strong) NSString *score_edit_time_fmt;
@property (nonatomic, strong) NSString *updated_reputation_review;
@property (nonatomic, strong) NSString *reviewee_score_status;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *reputation_score;
@property (nonatomic, strong) NSString *buyer_score;
@property (nonatomic, strong) NSString *reviewee_picture;
@property (nonatomic, strong) NSString *reviewee_name;
@property (nonatomic, strong) NSString *create_time_fmt;
@property (nonatomic, strong) NSString *reputation_id;
@property (nonatomic, strong) NSString *reviewee_uri;
@property (nonatomic, strong) NSString *reviewee_score;
@property (nonatomic, strong) NSString *seller_score;
@property (nonatomic, strong) NSString *inbox_id;
@property (nonatomic, strong) NSString *invoice_ref_num;
@property (nonatomic, strong) NSString *show_bookmark;
@property (nonatomic, strong) NSString *invoice_uri;
@property (nonatomic, strong) NSString *read_status;
@property (nonatomic, strong) NSString *create_time_ago;
@property (nonatomic, strong) NSString *reviewee_role;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *unassessed_reputation_review;
@property (nonatomic, strong) NSString *show_reviewee_score;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *reputation_inbox_id;
@property (nonatomic, strong) NSString *auto_read;
@property (nonatomic, strong) NSString *reputation_progress;
@property (nonatomic, strong) NSString *my_score_image;
@property (nonatomic, strong) NSString *their_score_image;
@property (nonatomic, strong) NSString *reputation_days_left;

@property (nonatomic, strong) NSString *review_status_description;
@property (nonatomic, strong) NSString *reputation_days_left_fmt;
@property (nonatomic, strong) NSString *buyer_id;
@property (nonatomic, strong) NSString *is_reviewer_score_edited;
@property (nonatomic, strong) NSString *is_reviewee_score_edited;
@property (nonatomic, strong) NSString *is_edited;
@property (nonatomic, strong) NSString *show_reputation_day;
@property (nonatomic, strong) NSString *create_time_fmt_ws;

@property (nonatomic, strong) ReputationDetail *user_reputation;
@property (nonatomic, strong) MyReviewReputationViewModel *viewModel;
@property (nonatomic, strong) ShopBadgeLevel *shop_badge_level;

+ (RKObjectMapping*)mapping;
@end
