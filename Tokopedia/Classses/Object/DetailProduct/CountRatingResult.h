//
//  CountRatingResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CCountScoreGood @"count_score_good"
#define CCountScoreBad @"count_score_bad"
#define CCountScoreNeutral @"count_score_neutral"

@interface CountRatingResult : NSObject
@property (nonatomic, strong) NSString *count_score_good;
@property (nonatomic, strong) NSString *count_score_bad;
@property (nonatomic, strong) NSString *count_score_neutral;

+(RKObjectMapping*)mapping;
@end
