//
//  ResolutionCenterDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxResolutionCenterList.h"

#pragma mark - Transaction Cart Payment Delegate
@protocol ResolutionCenterDetailViewControllerDelegate <NSObject>
@required
- (void)shouldCancelComplain:(InboxResolutionCenterList*)resolution atIndexPath:(NSIndexPath*)indexPath;
- (void)finishComplain:(InboxResolutionCenterList*)resolution atIndexPath:(NSIndexPath*)indexPath;
@end

@interface ResolutionCenterDetailViewController : UIViewController


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ResolutionCenterDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ResolutionCenterDetailViewControllerDelegate> delegate;
#endif

@property InboxResolutionCenterList *resolution;

@property NSIndexPath *indexPath;
@property NSString *resolutionID;

@end
