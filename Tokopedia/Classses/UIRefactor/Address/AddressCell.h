//
//  AddressCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ADDRRESS_CELL_IDENTIFIER @"AddressCellIdentifier"

#pragma mark - Address Cell Delegate
@protocol AddressCellDelegate <NSObject>
@required
-(void)AddressCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - SettingAddress Location Cell
@interface AddressCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<AddressCellDelegate> delegate;
@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
