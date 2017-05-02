//
//  TransactionCartEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionCartPaymentViewController;

#pragma mark - Transaction Cart Payment Delegate
@protocol TransactionCartEditViewControllerDelegate <NSObject>
@required
- (void)shouldEditCartWithUserInfo:(NSDictionary*)userInfo;

@end

@interface TransactionCartEditViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TransactionCartEditViewControllerDelegate> delegate;



@property (nonatomic,strong) NSDictionary *data;

@end
