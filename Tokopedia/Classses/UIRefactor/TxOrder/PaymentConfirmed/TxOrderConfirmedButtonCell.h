//
//  TxOrderConfirmedButtonCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUTTON_CELL_IDENTIFIER @"TxOrderConfirmedButtonCellIdentifier"

#pragma mark - Tx Order Button Cell Delegate
@protocol TxOrderConfirmedButtonCellDelegate <NSObject>
@required
- (void)uploadProofAtIndexPath:(NSIndexPath*)indexPath;
- (void)editConfirmation:(NSIndexPath*)indexPath;

@end

@interface TxOrderConfirmedButtonCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TxOrderConfirmedButtonCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TxOrderConfirmedButtonCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadProofButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actUploadProof;

+(id)newCell;

@end
