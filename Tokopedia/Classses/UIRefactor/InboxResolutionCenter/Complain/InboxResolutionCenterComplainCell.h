//
//  InboxResolutionCenterComplainCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INBOX_RESOLUTION_CENTER_MY_COMPLAIN_CELL_IDENTIFIER @"InboxResolutionCenterComplainCellIdentifier"

@interface InboxResolutionCenterComplainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *buyerProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *buyerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerOrSellerLabel;

@property (strong,nonatomic) NSString *disputeStatus;

@property (strong, nonatomic) NSIndexPath *indexPath;

+(id)newCell;

@end
