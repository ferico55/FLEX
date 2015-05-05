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


@property (nonatomic, weak) IBOutlet id<TransactionCartMandiriClickPayFormDelegate> delegate;


@property (nonatomic,strong) NSDictionary *data;

@end
