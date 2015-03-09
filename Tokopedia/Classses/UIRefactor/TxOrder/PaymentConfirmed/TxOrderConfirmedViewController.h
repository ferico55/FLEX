//
//  TxOrderConfirmedViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderConfirmedViewControllerDelegate <NSObject>
@required
-(void)uploadProof;
@end

@interface TxOrderConfirmedViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderConfirmedViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderConfirmedViewControllerDelegate> delegate;
#endif

@end
