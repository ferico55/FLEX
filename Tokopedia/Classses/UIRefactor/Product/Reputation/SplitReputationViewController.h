//
//  SplitReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 8/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SplitReputationVcProtocol
- (void)deallocVC;
@end


@interface SplitReputationViewController : UIViewController<UISplitViewControllerDelegate>
@property (nonatomic) UISplitViewController *splitViewController;
@property (nonatomic) BOOL isFromNotificationView;
@property (nonatomic, unsafe_unretained) id<SplitReputationVcProtocol> del;


- (void)setDetailViewController:(UIViewController *)viewController;
- (UINavigationController *)getMasterNavigation;
- (UINavigationController *)getDetailNavigation;
@end
