//
//  TxOrderConfirmationDetailHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TxOrderConfirmationDetailHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

+ (id)newview;

@end
