//
//  SkipReview.h
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkipReviewResult.h"

@interface SkipReview : NSObject
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) SkipReviewResult *result;
@property (nonatomic, strong) SkipReviewResult *data;

+ (RKObjectMapping*)mapping;

@end
