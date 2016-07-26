//
//  Statistic.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Statistic : NSObject

@property (nonatomic, strong) NSString *product_sold_count;
@property (nonatomic, strong) NSString *product_transaction_count;
@property (nonatomic, strong) NSString *product_success_rate;
@property (nonatomic, strong) NSString *product_view_count;
@property (nonatomic) NSInteger product_quality_rate;
@property (nonatomic) NSInteger product_accuracy_rate;
@property (nonatomic) NSInteger product_quality_point;
@property (nonatomic) NSInteger product_accuracy_point;
@property (nonatomic, strong) NSString *product_cancel_rate;
@property (nonatomic, strong) NSString *product_talk_count;
@property (nonatomic, strong) NSString *product_review_count;

+ (RKObjectMapping*)mapping;

@end
