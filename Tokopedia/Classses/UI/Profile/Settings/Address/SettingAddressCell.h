//
//  SettingAddressCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGADDRESSCELL_IDENTIFIER @"SettingAddressCellIdentifier"

@protocol SettingAddressCellDelegate <NSObject>
@required
-(void)SettingAddressCellDelegate:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface SettingAddressCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SettingAddressCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SettingAddressCellDelegate> delegate;
#endif

+(id)newcell;

@end
