//
//  SettingAddressLocationCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGADDRESSLOCATIONCELL_IDENTIFIER @"SettingAddressLocationCellIdentifier"

#pragma mark - Setting Address Location Cell Delegate
@protocol SettingAddressLocationCellDelegate <NSObject>
@required
-(void)SettingAddressLocationCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - SettingAddress Location Cell
@interface SettingAddressLocationCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressLocationCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressLocationCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
