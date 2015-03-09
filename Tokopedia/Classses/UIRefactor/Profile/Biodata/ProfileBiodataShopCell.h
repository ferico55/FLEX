//
//  ProfileBiodataShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StarsRateView.h"

#define kTKPDPROFILEBIODATASHOPCELLIDENTIFIER @"DetailProfileBiodataShopCellIdentifier"

@protocol ProfileBiodataShopCellDelegate <NSObject>

@required
-(void)ProfileBiodataShopCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface ProfileBiodataShopCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProfileBiodataShopCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProfileBiodataShopCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labellocation;
@property (weak, nonatomic) IBOutlet StarsRateView *ratespeed;
@property (weak, nonatomic) IBOutlet StarsRateView *rateaccuracy;
@property (weak, nonatomic) IBOutlet StarsRateView *rateservice;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;

+(id)newcell;

@end
