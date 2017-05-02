//
//  SettingAddressExpandedCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSETTINGADDRESSEXPANDEDCELL_IDENTIFIER @"SettingAddressExpandedCellIdentifier"


@interface SettingAddressExpandedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *recieverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

+(id)newcell;

@end
