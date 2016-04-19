//
//  NewOrderDeadline.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDeadline : NSObject <TKPObjectMapping>

@property NSInteger deadline_process_day_left;
@property NSInteger deadline_shipping_day_left;
@property NSInteger deadline_finish_day_left;
@property (strong, nonatomic) NSString *deadline_finish_date;

@end