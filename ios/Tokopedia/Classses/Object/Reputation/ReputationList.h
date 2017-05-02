//
//  DepositSummaryList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReputationList : NSObject

@property (nonatomic, strong) NSString *inbox_id;
@property (nonatomic, strong) NSString *reputation_id;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *seller_score;
@property (nonatomic, strong) NSString *buyer_score;
@property (nonatomic, strong) NSString *reviewee_name;
@property (nonatomic, strong) NSString *reviewee_uri;
@property (nonatomic, strong) NSString *reviewee_picture;
@property (nonatomic, strong) NSString *reviewee_score;
@property (nonatomic, strong) NSString *reviewee_score_status;
@property (nonatomic, strong) NSString *reviewee_role;
@property (nonatomic, strong) NSString *create_time_fmt;
@property (nonatomic, strong) NSString *create_time_ago;
@property (nonatomic, strong) NSString *invoice_ref_num;
@property (nonatomic, strong) NSString *invoice_uri;
@property (nonatomic, strong) NSString *show_reviewee_score;
@property (nonatomic, strong) NSString *read_status;

@end
