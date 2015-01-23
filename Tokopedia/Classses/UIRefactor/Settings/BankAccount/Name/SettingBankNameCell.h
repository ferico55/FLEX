//
//  SettingBankNameCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGBANKNAMECELL_IDENTIFIER @"SettingBankNameCellIdentifier"

#pragma mark - Setting Address Location Cell Delegate
@protocol SettingBankNameCellDelegate <NSObject>
@required
-(void)SettingBankNameCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SettingBankNameCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingBankNameCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingBankNameCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
