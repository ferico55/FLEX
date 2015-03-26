//
//  TxOrderConfirmationDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TxOrderConfirmationDetailViewController;

#pragma mark - Delegate
@protocol TxOrderConfirmationDetailViewControllerDelegate <NSObject>
@required
-(void)shouldCancelOrderAtIndexPath:(NSIndexPath *)indexPath viewController:(TxOrderConfirmationDetailViewController*)viewController;
-(void)didTapAlertCancelOrder;
@end

@interface TxOrderConfirmationDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderConfirmationDetailViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
