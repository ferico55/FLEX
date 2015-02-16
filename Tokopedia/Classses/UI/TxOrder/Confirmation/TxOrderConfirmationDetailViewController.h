//
//  TxOrderConfirmationDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Transaction Order Payment Confirmation Delegate
@protocol TxOrderPaymentConfirmationViewControllerDelegate <NSObject>
@required
-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TxOrderConfirmationDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderPaymentConfirmationViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderPaymentConfirmationViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
