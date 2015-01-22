//
//  TransactionCartFormMandiriClickPayViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionCartFormMandiriClickPayViewController;

#pragma mark - Transaction Cart Mandiri Form Delegate
@protocol TransactionCartMandiriClickPayFormDelegate <NSObject>
@required
- (void)TransactionCartMandiriClickPayForm:(TransactionCartFormMandiriClickPayViewController*)VC withUserInfo:(NSDictionary*)userInfo;
@end


@interface TransactionCartFormMandiriClickPayViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartMandiriClickPayFormDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartMandiriClickPayFormDelegate> delegate;
#endif

@property (nonatomic,strong) NSDictionary *data;

@end
