//
//  ResponseSpeed.h
//  Tokopedia
//
//  Created by Tokopedia on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResponseSpeed : NSObject <TKPObjectMapping>
@property (nonatomic, strong) NSDictionary *one_day;
@property (nonatomic, strong) NSDictionary *two_days;
@property (nonatomic, strong) NSDictionary *three_days;
@property (nonatomic, strong) NSString *speed_level;
@property (nonatomic, strong) NSString *badge;
@property (nonatomic, strong) NSString *count_total;
@end
