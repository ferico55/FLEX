//
//  TxOrderStatusDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderStatusList.h"
#import "InboxResolutionCenterList.h"

#pragma mark - Transaction Status Detail Delegate
@protocol TxOrderStatusDetailViewControllerDelegate <NSObject>
@required
-(void)confirmDeliveryAtIndexPath:(NSIndexPath *)indexPath;
-(void)delegateViewController:(UIViewController*)viewController;
-(void)reOrder:(TxOrderStatusList *)order atIndexPath:(NSIndexPath *)indexPath;
-(void)complainOrder:(TxOrderStatusList *)order;
- (void)shouldCancelComplain:(InboxResolutionCenterList*)resolution atIndexPath:(NSIndexPath*)indexPath;
-(void)complainAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TxOrderStatusDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TxOrderStatusDetailViewControllerDelegate> delegate;
@property (nonatomic , strong) TxOrderStatusList *order;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deliveredButton;
@property (strong, nonatomic) IBOutlet UIButton *complainButton;
@property (nonatomic) BOOL isComplain;
@property (nonatomic) BOOL reOrder;
@property (nonatomic) NSInteger buttonHeaderCount;
@property (nonatomic) NSIndexPath *indexPath;
@end
