//
//  TransactionCartViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Transaction Cart Cell Delegate
@protocol TransactionCartViewControllerDelegate <NSObject>
@required
- (void)didFinishRequestCheckoutData:(NSDictionary*)data;
- (void)didFinishRequestBuyData:(NSDictionary*)data;

@end

@interface TransactionCartViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartViewControllerDelegate> delegate;
#endif

@property (nonatomic) NSInteger indexPage;
@property (strong,nonatomic,setter=setData:) NSDictionary *data;

@end
