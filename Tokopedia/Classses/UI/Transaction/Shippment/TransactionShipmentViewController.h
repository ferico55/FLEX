//
//  TransactionShipmentViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionShipmentViewController;

@protocol TransactionShipmentViewControllerDelegate <NSObject>
@required
-(void)TransactionShipmentViewController:(TransactionShipmentViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface TransactionShipmentViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionShipmentViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionShipmentViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong)NSDictionary *data;

@end
