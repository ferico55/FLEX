//
//  SettingNotificationCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingNotificationCell;

#define kTKPDSETTINGNOTIFICATIONCELL_IDENTIFIER @"SettingNotificationCellIdentifier"

#pragma mark - Setting Address Location Cell Delegate
@protocol SettingNotificationCellDelegate <NSObject>
@required
-(void)SettingNotificationCell:(SettingNotificationCell*)cell withIndexPath:(NSIndexPath*)indexPath;

@end

@interface SettingNotificationCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<SettingNotificationCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *notificationName;
@property (weak, nonatomic) IBOutlet UILabel *notificationDetail;
@property (nonatomic, strong) NSIndexPath *indexPath;

+(id)newcell;

@end
