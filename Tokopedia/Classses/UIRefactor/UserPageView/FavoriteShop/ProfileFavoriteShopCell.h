//
//  ProfileFavoriteShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDPROFILEFAVORITESHOPCELL_IDENTIFIER @"ProfileFavoriteShopCellIdentifier"

@protocol ProfileFavoriteShopCellDelegate <NSObject>
@required
-(void)ProfileFavoriteShopCellDelegate:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface ProfileFavoriteShopCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<ProfileFavoriteShopCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *thumbfav;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;

@end
