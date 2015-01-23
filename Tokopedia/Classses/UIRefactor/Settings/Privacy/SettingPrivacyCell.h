//
//  SettingPrivacyCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingPrivacyCell;

#define kTKPDSETTINGPRIVACYCELL_IDENTIFIER @"SettingPrivacyCellIdentifier"

#pragma mark - Setting Privacy Cell Delegate
@protocol SettingPrivacyCellDelegate <NSObject>
@required
-(void)SettingPrivacyCell:(SettingPrivacyCell*)cell withIndexPath:(NSIndexPath*)indexPath;

@end

@interface SettingPrivacyCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingPrivacyCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingPrivacyCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *textCellLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;

+(id)newcell;

@end