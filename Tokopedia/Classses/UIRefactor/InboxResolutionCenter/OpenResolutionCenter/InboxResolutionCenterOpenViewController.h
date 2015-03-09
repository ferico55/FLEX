//
//  InboxResolutionCenterOpenViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderStatusList.h"
#import "GenerateHost.h"

#pragma mark - Transaction Cart Payment Delegate
@protocol InboxResolutionCenterOpenViewControllerDelegate <NSObject>
@required
- (void)updateDataSolution:(NSString*)selectedSolution refundAmount:(NSString*)refund remark:(NSString*)note;
@end

@interface InboxResolutionCenterOpenViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<InboxResolutionCenterOpenViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<InboxResolutionCenterOpenViewControllerDelegate> delegate;
#endif

@property TxOrderStatusList *order;
@property (nonatomic) BOOL isGotTheOrder;
@property NSInteger indexPage;
@property NSString *selectedProblem;
@property NSArray *uploadedPhotos;
@property GenerateHost *generatehost;

@end
