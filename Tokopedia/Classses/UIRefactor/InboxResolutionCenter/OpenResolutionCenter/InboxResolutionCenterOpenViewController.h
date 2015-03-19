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
@optional
- (void)updateDataSolution:(NSString*)selectedSolution refundAmount:(NSString*)refund remark:(NSString*)note;
- (void)changeSolution:(NSString*)solutionType troubleType:(NSString*)troubleType refundAmount:(NSString*)refundAmout remark:(NSString*)note photo:(NSString*)photo serverID:(NSString*)serverID;
- (void)appealSolution:(NSString*)solutionType refundAmount:(NSString*)refundAmout remark:(NSString*)note photo:(NSString*)photo serverID:(NSString*)serverID;
- (void)didFailureComplainOrder:(TxOrderStatusList*)order atIndexPath:(NSIndexPath*)indexPath;
@end

@interface InboxResolutionCenterOpenViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<InboxResolutionCenterOpenViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<InboxResolutionCenterOpenViewControllerDelegate> delegate;
#endif
@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;

@property NSString *controllerTitle;

@property TxOrderStatusList *order;
@property NSIndexPath *indexPath;

@property (nonatomic) BOOL isGotTheOrder;
@property NSInteger indexPage;
@property NSString *selectedProblem;
@property NSString *selectedSolution;
@property NSArray *uploadedPhotos;
@property GenerateHost *generatehost;

@property BOOL isChangeSolution;
@property BOOL isActionBySeller;
@property BOOL isCanEditProblem;
@property NSString *detailOpenAmount;
@property NSString *detailOpenAmountIDR;
@property NSString *shippingPriceIDR;
@property NSString *shopName;
@property NSString *shopPic;
@property NSString *invoice;
@property NSString *note;
@property NSString *totalRefund;

@end
