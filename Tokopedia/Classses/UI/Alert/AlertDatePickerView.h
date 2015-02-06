//
//  AlertDatePickerView.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDAlertView.h"
#import "string_alert.h"

@interface AlertDatePickerView : TKPDAlertView

@property (nonatomic, strong) NSDate *currentdate;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property BOOL isSetMinimumDate;

@end
