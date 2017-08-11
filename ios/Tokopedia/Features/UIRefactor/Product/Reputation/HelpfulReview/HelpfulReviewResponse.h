//
//  HelpfulReviewResponse.h
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelpfulReviewResult.h"

@interface HelpfulReviewResponse : NSObject
@property (nonatomic, strong) NSArray *config;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) HelpfulReviewResult *result;
@property (nonatomic, strong) HelpfulReviewResult *data;

+ (RKObjectMapping*)mapping;

@end
