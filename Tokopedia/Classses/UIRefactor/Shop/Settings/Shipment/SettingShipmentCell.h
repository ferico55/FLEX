//
//  SettingShipmentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGSHIPMENTCELLIDENTIFIER @"SettingShipmentCellIdentifier"

@protocol SettingShipmentCellDelegate <NSObject>
@required
-(void)SettingShipmentCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SettingShipmentCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingShipmentCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingShipmentCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *labelpackage;
@property (weak, nonatomic) IBOutlet UISwitch *switchpackage;
@property (nonatomic) NSInteger shipmentid;
@property (nonatomic) NSInteger packageid;
@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;

@end
