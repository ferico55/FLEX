//
//  SalesNewOrderViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewOrderDelegate <NSObject>

@optional
- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder;

@end

@interface SalesNewOrderViewController : GAITrackedViewController

@property (weak, nonatomic) id<NewOrderDelegate> delegate;

@end
