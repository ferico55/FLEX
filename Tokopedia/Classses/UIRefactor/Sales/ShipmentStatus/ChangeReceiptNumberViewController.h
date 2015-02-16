//
//  ChangeReceiptNumberViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeReceiptNumberDelegate <NSObject>

- (void)changeReceiptNumber:(NSString *)receiptNumber;

@end

@interface ChangeReceiptNumberViewController : UIViewController

@property (weak, nonatomic) id<ChangeReceiptNumberDelegate> delegate;

@end
