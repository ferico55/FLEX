//
//  TxOrderConfirmationDetailHeaderView.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderConfirmationDetailHeaderViewDelegate <NSObject>
@required
- (void)goToShopAtSection:(NSInteger)section;
- (void) goToInvoiceAtSection:(NSInteger)section;

@end


@interface TxOrderConfirmationDetailHeaderView : UIView


@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationDetailHeaderViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property NSInteger section;

+ (id)newview;

@end
