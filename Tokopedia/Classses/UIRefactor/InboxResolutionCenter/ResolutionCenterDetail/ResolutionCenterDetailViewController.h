//
//  ResolutionCenterDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxResolutionCenterList.h"

@class InboxResolutionCenterTabViewController;

#pragma mark - Transaction Cart Payment Delegate
@protocol ResolutionCenterDetailViewControllerDelegate <NSObject>
@required
- (void)shouldCancelComplain:(InboxResolutionCenterList*)resolution atIndexPath:(NSIndexPath*)indexPath;
- (void)finishComplain:(InboxResolutionCenterList*)resolution atIndexPath:(NSIndexPath*)indexPath;
@end

@interface ResolutionCenterDetailViewController : UIViewController

@property (strong, nonatomic) InboxResolutionCenterTabViewController*masterViewController;

@property (nonatomic, weak) IBOutlet id<ResolutionCenterDetailViewControllerDelegate> delegate;


@property InboxResolutionCenterList *resolution;

@property NSIndexPath *indexPath;
@property NSString *resolutionID;

-(void)replaceDataSelected:(InboxResolutionCenterList*)resolution indexPath:(NSIndexPath*)indexPath resolutionID:(NSString*)resolutionID;

@end
