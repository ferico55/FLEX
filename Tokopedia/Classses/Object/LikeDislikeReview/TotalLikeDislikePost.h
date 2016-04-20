//
//  TotalLikeDislikePost.h
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailTotalLikeDislike.h"
@class DetailTotalLikeDislike;

@interface TotalLikeDislikePost : NSObject
@property (nonatomic, strong) DetailTotalLikeDislike *total_like_dislike;
+(RKObjectMapping*)mapping;
@end
