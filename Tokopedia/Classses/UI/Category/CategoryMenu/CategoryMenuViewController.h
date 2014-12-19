//
//  CategoryMenuViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryMenuViewController;

@protocol CategoryMenuViewDelegate <NSObject>
@required
-(void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary*)userInfo;

@end

@interface CategoryMenuViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<CategoryMenuViewDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<CategoryMenuViewDelegate> delegate;
#endif

@property (strong,nonatomic)NSDictionary *data;

@end
