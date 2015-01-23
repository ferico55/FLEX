//
//  SortViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SortViewController;

@protocol SortViewControllerDelegate <NSObject>
@required
-(void)SortViewController:(SortViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface SortViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SortViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SortViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, weak) UIImage *screenshotImage;

@end
