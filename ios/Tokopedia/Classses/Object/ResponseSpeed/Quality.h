//
//  Quality.h
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CRatingStar @"rating_star"
#define CAverage @"average"
#define COneStarRank @"one_star_rank"
#define CCountTotal @"count_total"
#define CFourStarRank @"four_star_rank"
#define CFiveStarRank @"five_star_rank"
#define CTwoStarRank @"two_star_rank"
#define CThreeStarRank @"three_star_rank"

@interface Quality : NSObject
@property (nonatomic, strong) NSString *rating_star;
@property (nonatomic, strong) NSString *average;
@property (nonatomic, strong) NSString *one_star_rank;
@property (nonatomic, strong) NSString *count_total;
@property (nonatomic, strong) NSString *four_star_rank;
@property (nonatomic, strong) NSString *five_star_rank;
@property (nonatomic, strong) NSString *two_star_rank;
@property (nonatomic, strong) NSString *three_star_rank;

+(RKObjectMapping*)mapping;
@end
