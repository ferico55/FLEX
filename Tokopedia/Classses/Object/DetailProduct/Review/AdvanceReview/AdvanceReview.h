//
//  AdvanceReview.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RatingList.h"

@interface AdvanceReview : NSObject

@property (nonatomic, strong) NSArray *rating_list;
@property (nonatomic) NSInteger netral_quality_point;
@property (nonatomic) NSInteger negative_accuracy_point;
@property (nonatomic) float rating_accuracy_point;
@property (nonatomic) float negative_quality_point;
@property (nonatomic) float positive_quality_point;
@property (nonatomic) float netral_accuracy_point;
@property (nonatomic) float positive_accuracy_point;
@property (nonatomic) NSInteger total_review;
@property (nonatomic) float rating_quality_point;

@end
