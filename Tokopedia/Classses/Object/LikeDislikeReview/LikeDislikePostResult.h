//
//  LikeDislikePostResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CContent @"content"
#define CIsSuccess @"is_success"
@class TotalLikeDislikePost;

@interface LikeDislikePostResult : NSObject
@property (nonatomic, strong) TotalLikeDislikePost *content;
@property (nonatomic, strong) NSString *is_success;
@end
