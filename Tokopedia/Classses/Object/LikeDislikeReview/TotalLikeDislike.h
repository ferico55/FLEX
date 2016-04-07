//
//  TotalLikeDislike.h
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailTotalLikeDislike.h"
#define CLikeStatus @"like_status"
#define CReviewID @"review_id"
#define CTotalLikeDislike @"total_like_dislike"

@interface TotalLikeDislike : NSObject
@property (nonatomic, strong) NSString *like_status;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) DetailTotalLikeDislike *total_like_dislike;

+(RKObjectMapping*) mapping;
@end
