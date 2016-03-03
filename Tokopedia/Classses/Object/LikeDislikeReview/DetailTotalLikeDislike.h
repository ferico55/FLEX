//
//  DetailTotalLikeDislike.h
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CTotalLike @"total_like"
#define CTotalDislike @"total_dislike"

@interface DetailTotalLikeDislike : NSObject
@property (nonatomic, strong) NSString *total_like;
@property (nonatomic, strong) NSString *total_dislike;

+(RKObjectMapping*)mapping;
@end
