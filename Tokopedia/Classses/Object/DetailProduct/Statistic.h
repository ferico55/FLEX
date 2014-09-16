//
//  Statistic.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Statistic : NSObject

@property (nonatomic, strong) NSString *product_sold;
@property (nonatomic, strong) NSString *product_transaction;
@property (nonatomic, strong) NSString *product_success_rate;
@property (nonatomic, strong) NSString *product_view;
@property (nonatomic) NSInteger product_rating;
@property (nonatomic, strong) NSString *product_cancel_rate;
@property (nonatomic, strong) NSString *product_talk;
@property (nonatomic, strong) NSString *product_review;

@end
