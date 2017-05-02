//
//  ProfileBiodataShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarsRateView.h"
@class ShopBadgeLevel;

#define kTKPDPROFILEBIODATASHOPCELLIDENTIFIER @"DetailProfileBiodataShopCellIdentifier"

@protocol ProfileBiodataShopCellDelegate <NSObject>

@required
-(void)ProfileBiodataShopCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;
- (void)actionReputasi:(id)sender;
- (void)actionKecepatan:(id)sender;
@end


@interface ProfileBiodataShopCell : UITableViewCell
{
    IBOutlet UIButton *btnReputasi, *btnKecepatan;
}

@property (nonatomic, weak) IBOutlet id<ProfileBiodataShopCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UIButton *buttonName;
@property (weak, nonatomic) IBOutlet UILabel *labellocation;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;

+(id)newcell;
- (void)generateMedal:(ShopBadgeLevel *)shopBadgeLevel;
- (void)setBadgeIcon:(NSString *)badge;
- (IBAction)actionReputasi:(id)sender;
- (IBAction)actionKecepatan:(id)sender;
@end
