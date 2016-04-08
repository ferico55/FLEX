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
#import "Tokopedia-Swift.h"

#pragma mark - Delegate
@protocol InboxResolutionCenterOpenViewControllerDelegate <NSObject>
@optional
-(void)setGenerateHost:(GeneratedHost*)generateHost;
- (void)updateDataSolution:(NSString*)selectedSolution refundAmount:(NSString*)refund remark:(NSString*)note;
- (void)changeSolution:(NSString*)solutionType troubleType:(NSString*)troubleType refundAmount:(NSString*)refundAmout remark:(NSString*)note photo:(NSString*)photo serverID:(NSString*)serverID isGotTheOrder:(BOOL)isGotTheOrder;
- (void)appealSolution:(NSString*)solutionType refundAmount:(NSString*)refundAmout remark:(NSString*)note photo:(NSString*)photo serverID:(NSString*)serverID;
- (void)didFailureComplainOrder:(TxOrderStatusList*)order atIndexPath:(NSIndexPath*)indexPath;
@end

@protocol SyncroDelegate <NSObject>
@optional
- (void)syncroImages:(NSArray*)images message:(NSString*)message refundAmount:(NSString*)refundAmount;
@end


@interface InboxResolutionCenterOpenViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<InboxResolutionCenterOpenViewControllerDelegate> delegate;



@property (nonatomic, weak) IBOutlet id<SyncroDelegate> syncroDelegate;


@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;

@property (nonatomic) NSString *controllerTitle;

@property TxOrderStatusList *order;
@property NSIndexPath *indexPath;

@property (nonatomic) BOOL isGotTheOrder;
@property NSInteger indexPage;
@property NSString *selectedProblem;
@property NSString *selectedSolution;
@property NSArray *uploadedPhotos;
@property (nonatomic, strong) GenerateHost *generatehost;

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

@property NSArray <DKAsset*>*images;

@end
