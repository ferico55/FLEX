//
//  Quality.h
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


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
