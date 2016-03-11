//
//  SubmitReview.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubmitReviewResult.h"

@interface SubmitReview : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) SubmitReviewResult *data;

+ (RKObjectMapping*)mapping;

@end
