//
//  LikeDislikeResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TotalLikeDislike.h"
#define CLikeDislikeReview @"like_dislike_review"

@interface LikeDislikeResult : NSObject
@property (nonatomic, strong) NSArray *like_dislike_review;

+(RKObjectMapping*) mapping;
@end
