//
//  SubmitReviewResult.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubmitReviewResult : NSObject

@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) NSString *post_key;

+ (RKObjectMapping*)mapping;

@end
