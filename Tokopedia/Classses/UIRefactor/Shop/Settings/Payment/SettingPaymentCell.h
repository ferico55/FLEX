//
//  SettingPaymentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGPAYMENTCELL_IDENTIFIER @"SettingPaymentCellIdentifier"

#pragma mark - Setting Payment Cell Delegate
@protocol SettingPaymentCellDelegate <NSObject>
@required
-(void)SettingPaymentCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SettingPaymentCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingPaymentCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingPaymentCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UISwitch *switchpayment;
@property (weak, nonatomic) IBOutlet UILabel *labeldescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonterms;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UITextView *textviewdesc;

+ (id)newcell;

@end
