//
//  TransactionCartShippingViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionCartShippingViewController;

#pragma mark - Transaction Cart Shipment Delegate
@protocol TransactionCartShippingViewControllerDelegate <NSObject>
@required
- (void)TransactionCartShipping:(TransactionCartList*)cart;

@end

@interface TransactionCartShippingViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TransactionCartShippingViewControllerDelegate> delegate;


@property (nonatomic) NSInteger indexPage;
@property (nonatomic, strong) TransactionCartList *cart;

@end
