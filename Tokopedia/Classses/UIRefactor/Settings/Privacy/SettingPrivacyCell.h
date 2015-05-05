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


@property (nonatomic, weak) IBOutlet id<SettingPrivacyCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *textCellLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;

+(id)newcell;

@end