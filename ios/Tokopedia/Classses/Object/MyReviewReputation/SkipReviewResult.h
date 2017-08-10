//
//  SkipReviewResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkipReviewResult : NSObject
@property (nonatomic, strong) NSString *reputation_review_counter;
@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *show_bookmark;

+ (RKObjectMapping*)mapping;

@end
