//
//  TxOrderConfirmationViewController.h
//  l
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Transaction Cart Payment Delegate
@protocol TxOrderConfirmationViewControllerDelegate <NSObject>
@required
- (void)isNodata:(BOOL)isNodata;

@end

@interface TxOrderConfirmationViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationViewControllerDelegate> delegate;

@property (nonatomic) BOOL isMultipleSelection;
@property (nonatomic) BOOL isSelectAll;

-(void)removeAllSelected;

@end
