//
//  SalesOrderCell.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderButtonView,OrderTransaction;

@protocol SalesOrderCellDelegate <NSObject>

@optional
- (void)tableViewCell:(UITableViewCell *)cell didSelectPriceAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell didSelectUserAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SalesOrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *automaticallyCanceledLabel;

@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *paymentAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;

@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<SalesOrderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UILabel *lastStatusLabel;

@property (nonatomic) BOOL isNewOrder;
@property (nonatomic, strong) OrderTransaction *order;

- (void)removeAllButtons;
- (void)showAcceptButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showRejectButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showPickUpButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showChangeCourierButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showConfirmButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showCancelButtonOnTap:(void(^)(OrderTransaction*))onTap;
- (void)showAskBuyerButtonOnTap:(void(^)(OrderTransaction*))onTap;

@end
