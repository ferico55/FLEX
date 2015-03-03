//
//  AlertInfoVoucherCodeView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface AlertReputation : TKPDAlertView

@property (weak, nonatomic) IBOutlet UIButton *happyButton;
@property (weak, nonatomic) IBOutlet UIButton *netralButton;
@property (weak, nonatomic) IBOutlet UIButton *unhappyButton;

@property (weak, nonatomic) IBOutlet UILabel *shopRatingLabel;

@end
