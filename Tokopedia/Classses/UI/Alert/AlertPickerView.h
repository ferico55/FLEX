//
//  AlertPickerView.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDAlertView.h"
#import "string_alert.h"

@interface AlertPickerView : TKPDAlertView

@property (strong,nonatomic) NSArray *pickerData;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end
