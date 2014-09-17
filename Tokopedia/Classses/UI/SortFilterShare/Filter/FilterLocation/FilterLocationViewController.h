//
//  FilterLocationViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterLocationViewControllerDelegate <NSObject>
@required
-(void)FilterLocationViewController:(UIViewController*)viewcontroller withdata:(NSDictionary*)data;

@end


@interface FilterLocationViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<FilterLocationViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<FilterLocationViewControllerDelegate> delegate;
#endif

@end
