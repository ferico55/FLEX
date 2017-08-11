//
//  LikeDislikePost.h
//  Tokopedia
//
//  Created by Tokopedia on 7/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LikeDislikePostResult.h"

@class LikeDislikePostResult;

@interface LikeDislikePost : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) LikeDislikePostResult *data;

+ (RKObjectMapping*)mapping;
@end
