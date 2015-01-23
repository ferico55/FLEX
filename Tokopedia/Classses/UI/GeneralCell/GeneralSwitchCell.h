//
//  GeneralSwitchCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GeneralSwitchCell;

#define GENERAL_SWITCH_CELL_IDENTIFIER @"GeneralSwitchCellIdentifier"

#pragma mark - Setting Privacy Cell Delegate
@protocol GeneralSwitchCellDelegate <NSObject>
@required
-(void)GeneralSwitchCell:(GeneralSwitchCell*)cell withIndexPath:(NSIndexPath*)indexPath;

@end

@interface GeneralSwitchCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GeneralSwitchCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GeneralSwitchCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *textCellLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;

+(id)newcell;

@end
