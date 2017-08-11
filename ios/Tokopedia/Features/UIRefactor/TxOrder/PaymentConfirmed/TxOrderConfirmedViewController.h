//
//  TxOrderConfirmedViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderConfirmedList.h"

#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderConfirmedViewControllerDelegate <NSObject>

@required
- (void)setIsRefresh:(BOOL)isRefresh;

@optional
-(void)editPayment:(TxOrderConfirmedList*)object;

@end

@interface TxOrderConfirmedViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TxOrderConfirmedViewControllerDelegate> delegate;


@property BOOL isRefresh;

@end
