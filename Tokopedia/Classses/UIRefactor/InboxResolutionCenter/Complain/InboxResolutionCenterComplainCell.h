//
//  InboxResolutionCenterComplainCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Delegate
@protocol InboxResolutionCenterComplainCellDelegate <NSObject>
@required
- (void)goToInvoiceAtIndexPath:(NSIndexPath*)indexPath;
- (void)goToShopOrProfileAtIndexPath:(NSIndexPath*)indexPath;
- (void)goToResolutionDetailAtIndexPath:(NSIndexPath*)indexPath;
- (void)showImageAtIndexPath:(NSIndexPath*)indexPath;

@end


#define INBOX_RESOLUTION_CENTER_MY_COMPLAIN_CELL_IDENTIFIER @"InboxResolutionCenterComplainCellIdentifier"

@interface InboxResolutionCenterComplainCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<InboxResolutionCenterComplainCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *buyerProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *buyerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerOrSellerLabel;

@property (strong,nonatomic) NSString *disputeStatus;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadBorderView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadIconImageView;

+(id)newCell;

@end
