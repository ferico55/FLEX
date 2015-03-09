//
//  TxOrderStatusDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderStatusList.h"

#pragma mark - Transaction Status Detail Delegate
@protocol TxOrderStatusDetailViewControllerDelegate <NSObject>
@required
-(void)confirmDelivery:(TxOrderStatusList *)order atIndexPath:(NSIndexPath*)indexPath;
-(void)reOrder:(TxOrderStatusList *)order atIndexPath:(NSIndexPath *)indexPath;
-(void)complainOrder:(TxOrderStatusList *)order;
@end

@interface TxOrderStatusDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderStatusDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderStatusDetailViewControllerDelegate> delegate;
#endif

@property (nonatomic , strong) TxOrderStatusList *order;

@property (nonatomic) BOOL isComplain;
@property (nonatomic) BOOL reOrder;
@property (nonatomic) NSInteger buttonHeaderCount;
@property (nonatomic) NSIndexPath *indexPath;
@end
