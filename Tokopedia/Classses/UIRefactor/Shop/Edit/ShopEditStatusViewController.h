//
//  ShopEditStatusViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopEditStatusViewControllerDelegate <NSObject>
@required
-(void)ShopEditStatusViewController:(UIViewController*)vc withData:(NSDictionary*)data;

@end

@interface ShopEditStatusViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ShopEditStatusViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ShopEditStatusViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary *data;

@end
