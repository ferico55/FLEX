//
//  SalesNewOrderViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tokopedia-Swift.h"

@protocol NewOrderDelegate <NSObject>

@optional
- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder;

@end

@interface SalesNewOrderViewController : UIViewController

@property (weak, nonatomic) id<NewOrderDelegate> delegate;

@end
