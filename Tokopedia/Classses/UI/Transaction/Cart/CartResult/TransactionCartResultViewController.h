//
//  TransactionCartResultViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionCartResultViewControllerDelegate <NSObject>
@required
- (void)shouldBackToFirstPage;

@end

@interface TransactionCartResultViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartResultViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartResultViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
