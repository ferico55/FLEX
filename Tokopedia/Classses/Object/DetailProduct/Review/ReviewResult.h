//
//  ReviewResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdvanceReview.h"
#import "ReviewList.h"
#import "Paging.h"
#define CPaging @"paging"
#define CAdvanceReview @"advance_review"
#define CList @"list"

@interface ReviewResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) AdvanceReview *advance_review;
@property (nonatomic, strong) NSString *is_owner;
@property (nonatomic, strong) NSArray *list;

@end
