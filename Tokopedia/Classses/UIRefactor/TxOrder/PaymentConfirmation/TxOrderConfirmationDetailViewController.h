//
//  TxOrderConfirmationDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TxOrderConfirmationDetailViewController;
#import "TxOrderConfirmationList.h"

#pragma mark - Delegate
@protocol TxOrderConfirmationDetailViewControllerDelegate <NSObject>
@required
-(void)didCancelOrder:(TxOrderConfirmationList*)order;
@end

@interface TxOrderConfirmationDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TxOrderConfirmationDetailViewControllerDelegate> delegate;

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
