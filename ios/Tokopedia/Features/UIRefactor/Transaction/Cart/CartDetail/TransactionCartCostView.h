//
//  TransactionCartCostView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionCartList.h"

@interface TransactionCartCostView : UIView

@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingCostLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *biayaInsuranceLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

+(id)newview;
-(void)setViewModel:(CartModelView*)viewModel;

@end
