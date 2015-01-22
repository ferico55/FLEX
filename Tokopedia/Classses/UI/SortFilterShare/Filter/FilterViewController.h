//
//  FilterViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//


#import <UIKit/UIKit.h>
@class FilterViewController;

#pragma mark - Filter View Controller Delegate
@protocol FilterViewControllerDelegate <NSObject>
@required
-(void)FilterViewController:(FilterViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

#pragma mark - Filter View Controller
@interface FilterViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<FilterViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<FilterViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;

@end
